require 'rails_helper'

describe 'Admin creates a new trader' do
  it 'allows admin to create a trader user' do
    admin = User.create!(email: 'admin@example.com', password: 'password', role: 'admin', approved: true)
    trader = User.create!(email: 'trader@example.com', password: 'password', role: 'trader', approved: true)

    expect(trader).to be_persisted
    expect(trader.role).to eq('trader')
    expect(trader.approved).to be true
  end
end
