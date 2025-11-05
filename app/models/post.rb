class Post < ApplicationRecord
  belongs_to :user
  has_rich_text :content

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, presence: true

  before_validation :generate_slug, if: -> { title.present? && slug.blank? }
  before_save :set_published_at, if: -> { published? && published_at.nil? }

  scope :published, -> { where(published: true).order(published_at: :desc) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = title.parameterize
  end

  def set_published_at
    self.published_at = Time.current
  end
end
