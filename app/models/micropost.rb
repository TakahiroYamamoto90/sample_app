class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size:         { less_than: 5.megabytes,
                                      message:   "should be less than 5MB" }

  def self.ransackable_attributes(auth_object = nil)
    # nameとnicknameは検索OKとする（ただし管理者は自由に検索可）
    auth_object ? super : %w(content)
  end

  def self.ransackable_associations(auth_object = nil)
    # 関連先のモデルを検索する必要がなければ空の配列を返す
    auth_object ? super : []
  end                                      
end
