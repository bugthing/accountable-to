# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def confirmation_email
    UserMailer.confirmation_email(user_for_confirmation)
  end

  def magic_link_email
    UserMailer.magic_link_email(user_for_magic_link)
  end

  private

  def user_for_confirmation
    User.where.not(confirmation_token: nil).first || User.create!(email: "test@example.com", confirmation_token: "123456")
  end

  def user_for_magic_link
    User.where.not(magic_link_token: nil).first || User.create!(email: "test@example.com", confirmed_at: Time.current, magic_link_token: "abcdef")
  end
end
