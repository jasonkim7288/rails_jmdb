class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    
    puts "********************************"
    p resource
    p resource[:full_name]
    puts "********************************"
    root_path
  end
end