class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    if resource
      WelcomeMailer.with(email: resource[:email], full_name: resource[:full_name]).welcome_email.deliver_later
    end
    root_path
  end
end