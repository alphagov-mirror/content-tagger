class TaggingSpreadsheet < ActiveRecord::Base
  validates :url, presence: true
  validates_presence_of :state
  validates_inclusion_of :state, in: %w(uploaded errored ready_to_import imported)

  has_many :tag_mappings, dependent: :delete_all
  scope :newest_first, -> { order(created_at: :desc) }
  scope :active, -> { where(deleted_at: nil) }

  def mark_as_deleted
    update(deleted_at: DateTime.current)
  end
end
