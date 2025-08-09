class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        resource.update(role: 'trader', approved: false)
      end
    end
  end
end
