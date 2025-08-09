require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  it 'responds successfully to a GET request' do
    get :new rescue nil
    expect(response).to be_successful.or be_redirect
  end
end
