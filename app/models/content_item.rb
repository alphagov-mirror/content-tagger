class ContentItem
  TAG_TYPES = %w(mainstream_browse_pages parent topics organisations alpha_taxons)

  attr_reader :content_id, :title, :format, :base_path, :publishing_app

  def initialize(data)
    @content_id = data.fetch('content_id')
    @title = data.fetch('title')
    @format = data.fetch('format')
    @base_path = data.fetch('base_path')
    @publishing_app = data.fetch('publishing_app')
  end

  def self.find!(content_id)
    content_item = Services.publishing_api.get_content(content_id)
    raise ItemNotFoundError unless content_item
    new(content_item.to_h)
  end

  def link_set
    @link_set ||= LinkSet.find(content_id)
  end

  def tagging_allowed?
    app_responsible_for_tagging == "content-tagger"
  end

  def app_responsible_for_tagging
    return if format.in?(%w(redirect gone))

    @tagging_apps ||= YAML.load_file("#{Rails.root}/config/tagging-apps.yml")
    @tagging_apps[publishing_app]
  end

  def external_tagging_url
    if app_responsible_for_tagging == 'whitehall'
      Plek.new.find('whitehall-admin')
    else
      Plek.new.find(app_responsible_for_tagging)
    end
  end

  def blacklisted_tag_types
    # FIXME: This is  a temporary workaround for the fact that 'parent' links
    # can sometimes be blobs of JSON (containing a breadcrumb, for example)
    # rather than the array of content IDs content-tagger currently expects. We
    # need to either improve the editing interface in content tagger to somehow
    # support this or wait until the publishing API no longer allows writing of
    # arbitrary JSON to the parent link.
    #
    # If we have to do any more of this consider moving it out into a separate
    # piece of configuration (perhaps something like the tagging-apps.yml).
    if publishing_app == "travel-advice-publisher"
      %w(parent)
    else
      []
    end
  end

  class ItemNotFoundError < StandardError
  end
end
