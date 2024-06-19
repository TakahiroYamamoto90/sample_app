# Preview all emails at https://fantastic-fishstick-q54xjjrqgqc6w67-3000.app.github.dev/rails/mailers/relationship_mailer
class RelationshipMailerPreview < ActionMailer::Preview

  def follow_notification
    user = User.first
    follower = User.second
    RelationshipMailer.follow_notification(user, follower)
  end

  def unfollow_notification
    user = User.first
    follower = User.second
    RelationshipMailer.unfollow_notification(user, follower)
  end
end
