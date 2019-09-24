require "rails_helper"

RSpec.describe "GET /healthcheck", type: :request do
  it "should respond with 'OK'" do
    get "/healthcheck"

    expect(response.status).to eq(200)
    expect(response.body).to eq("OK")
  end
end
