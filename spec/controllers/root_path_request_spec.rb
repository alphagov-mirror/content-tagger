require 'rails_helper'

RSpec.describe "Root Path", type: :request do
  describe "as a GDS Editor" do
    it "redirects to 'Edit a page'" do
      login_as create(:user, :gds_editor)
      get root_path
      expect(response).to redirect_to lookup_taggings_path
    end
  end

  describe "as a tagathon participant" do
    it "redirects to 'Projects'" do
      login_as create(:user, :tagathon_participant)
      get root_path
      expect(response).to redirect_to projects_path
    end
  end

  describe "as an unprivileged user" do
    it "denies access" do
      login_as create(:user)
      get root_path
      expect(response.code).to eql "403"
    end
  end
end