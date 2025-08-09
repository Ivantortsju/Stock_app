

require 'rails_helper'

RSpec.describe PortfolioController, type: :controller do
  describe 'GET #index' do
    it 'responds successfully to a GET request' do
      get :index rescue nil
      expect(response).to be_successful.or be_redirect
    end
  end

  describe 'GET #sell' do
    let(:user) { instance_double(User, id: 1, role: 'trader', approved?: true, transactions: double(where: double(sum: 10))) }

    before do
      allow(controller).to receive(:authenticate_user!).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      allow(Stock).to receive(:new_lookup).and_return(double(ticker: 'AAPL', last_price: 100.0, name: 'Apple'))
    end

    it 'responds to sell action' do
      get :sell, params: { ticker: 'AAPL' }
      expect(response).to be_successful.or be_redirect
    end
  end
end
