class WelcomeMailer < ApplicationMailer
  def welcome_email
    @full_name = params[:full_name]
    mail(to: params[:email], subject: "Hello #{@full_name}, Welcome to JMDb!")
  end
end
