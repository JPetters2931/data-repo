require 'spec_helper'

describe DatarepoFileEditForm do
  subject { described_class.new(GenericFile.new) }

  describe "#terms" do
    it "returns a list" do
      expect(subject.terms).to match_array([:resource_type, :title, :creator, :contributor, :description, :tag, :rights, :publisher,
                                   :date_created, :subject, :language, :identifier, :based_near, :related_url, :provenance])
    end
  end

  it "initializes provenance field" do
    expect(subject.provenance).to match_array([""])
  end

  describe ".model_attributes" do
    let(:params) { ActionController::Parameters.new(provenance: ['foo'], description: [''], "permissions_attributes" => { "2" => { "access" => "edit", "_destroy" => "true", "id" => "a987551e-b87f-427a-8721-3e5942273125" } }) }
    subject { described_class.model_attributes(params) }

    it "only changes provenance" do
      expect(subject['provenance']).to match_array(["foo"])
      expect(subject['description']).to be_empty
      expect(subject['permissions_attributes']).to eq("2" => { "access" => "edit", "id" => "a987551e-b87f-427a-8721-3e5942273125", "_destroy" => "true" })
    end
  end
end
