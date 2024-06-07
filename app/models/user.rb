class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  #before_save { self.email = email.downcase }
  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name,
    presence: true,
    length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, 
    presence: true, 
    length: { maximum: 255 }, 
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 9 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  #def User.digest(string)
  #def self.digest(string)
  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      # BCrypt::Password.createでハッシュ化文字列を生成（暗号化）
      BCrypt::Password.create(string, cost: cost)
    end

  # ランダムなトークンを返す
  #def User.new_token
  #def self.new_token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    # このselfはクラスそのものを参照する(≠インスタンス)
    self.remember_token = User.new_token
    # 属性ハッシュ:remember_digestにremember_tokenをはハッシュ化した文字列をセットする
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest # self.remember_digest
    #binding.break
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end  

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  #def authenticated?(remember_token)
  #  return false if remember_digest.nil?
  #  # BCrypt::Password.newでハッシュ化文字列remember_digestを生パスワードに復号
  #  BCrypt::Password.new(remember_digest).is_password?(remember_token)
  #end
  # attributeパラメータでどのdigestかを切り替えできるようにする
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end  

  # ユーザーのログイン情報を破棄する
  # インスタンスメソッド
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    #update_attribute(:activated,    true)
    #update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end  

  private
    # メールアドレスをすべて小文字にする
    def downcase_email
      #self.email = email.downcase
      self.email.downcase!
    end
    
    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end    
end
