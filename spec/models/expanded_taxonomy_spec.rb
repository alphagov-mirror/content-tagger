require "rails_helper"

RSpec.describe ExpandedTaxonomy do
  def fake_taxon(title)
    { "title" => title, "content_id" => "#{title.parameterize}-id" }
  end

  # parent taxons
  let(:red_things) { fake_taxon("Red-Things") }
  let(:food) { fake_taxon("Food") }
  let(:fruits) do
    fake_taxon("Fruits").merge(
      "links" => {
        "parent_taxons" => [food]
      }
    )
  end

  # our 'root' taxon
  let(:apples) { fake_taxon("Apples") }

  # child taxons
  let(:bramley) { fake_taxon("Bramley") }
  let(:cox) { fake_taxon("Cox") }

  before do
    publishing_api_has_item(apples)

    publishing_api_has_expanded_links(
      content_id: apples["content_id"],
      expanded_links: {
        parent_taxons: [fruits, red_things],
        child_taxons: [bramley, cox],
      },
    )

    publishing_api_has_expanded_links(
      content_id: bramley["content_id"],
      expanded_links: {
        parent_taxons: [apples]
      }
    )

    publishing_api_has_expanded_links(
      content_id: cox["content_id"],
      expanded_links: {
        parent_taxons: [apples]
      }
    )
  end

  describe "#build" do
    it "returns a representation of the taxonomy, with both parent and child taxons expanded" do
      taxonomy = ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.root_node.title).to eq apples["title"]
      expect(taxonomy.parent_expansion.map(&:title)).to eq %w(Apples Fruits Food Red-Things)
      expect(taxonomy.parent_expansion.map(&:node_depth)).to eq [0, 1, 2, 1]
      expect(taxonomy.child_expansion.map(&:title)).to eq %w(Apples Bramley Cox)
      expect(taxonomy.child_expansion.map(&:node_depth)).to eq [0, 1, 1]
    end
  end

  describe "#immediate_parents" do
    it "returns immediate parents of the root node" do
      taxonomy = ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.immediate_parents.map(&:title)).to eq %w(Fruits Red-Things)
    end
  end

  describe "#immediate_children" do
    it "returns immediate children of the root node" do
      taxonomy = ExpandedTaxonomy.new(apples["content_id"]).build

      expect(taxonomy.immediate_children.map(&:title)).to eq %w(Bramley Cox)
    end
  end
end
