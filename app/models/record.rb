class Record < ApplicationRecord
  belongs_to :account
  belongs_to :plan, optional: true
  belongs_to :fixed, optional: true

  validates :category, :note, :amount, :result, :account, presence: true
  validate :account_balance_cannot_be_zero
  validate :cannot_create_income_record

  def account_balance_cannot_be_zero
    if !id.present? || Record.find(id).fixed == fixed
      if id.present? && (Record.find(id).amount != amount)
        if !income && (account.balance - (amount - Record.find(id).amount)).negative?
          errors.add(:amount, "Este monto dejaría la cuenta con un monto menor quer 0. Monto actual: #{account.balance}")
        end
      elsif !income && amount.present? && account.present? && (account.balance - amount).negative?
        errors.add(:amount, "Este monto dejaría la cuenta con un monto menor quer 0. Monto actual: #{account.balance}")
      end
    end
  end
  def cannot_create_income_record
    if plan.present? && plan.status && income
      errors.add(:amount, "No se pueden crear registros de ingresos cuando el plan está completado.")
    end
  end
end
