class User < ApplicationRecord
  has_many :transactions, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  after_create :set_default_funds

  def active_for_authentication?
    super && (approved? || role == 'admin')
  end

  def inactive_message
    approved? ? super : :not_approved
  end

  private

  def set_default_funds
    if role == 'admin'
      update_column(:funds, 1_000_000)
    elsif role == 'trader'
      update_column(:funds, 10_000)
    end
  end
end
