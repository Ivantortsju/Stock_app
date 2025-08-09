require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  it 'can be instantiated' do
    expect(ApplicationController.new).to be_a(ApplicationController)
  end
end
