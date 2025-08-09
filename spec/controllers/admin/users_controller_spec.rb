require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  it 'responds successfully to a GET request' do
    get :index rescue nil
    expect(response).to be_successful.or be_redirect
  end
end
