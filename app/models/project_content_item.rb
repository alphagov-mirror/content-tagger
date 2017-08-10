class ProjectContentItem < ActiveRecord::Base
  belongs_to :project

  def base_path
    url.gsub('https://www.gov.uk', '')
  end

  # taxons don't exist
  def taxons
    []
  end

  def mark_complete
    update_attributes(done: true)
  end

  scope :uncompleted, -> { where(done: false) }
end