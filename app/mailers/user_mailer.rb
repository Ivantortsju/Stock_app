class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def account_approved_email(user)
    @user = user
    mail(to: @user.email, subject: 'Your account has been approved')
  end
end
