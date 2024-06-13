require "test_helper"

class RelationshipMailerTest < ActionMailer::TestCase
  test "follow_notification" do
    user = users(:archer)
    follower = users(:michael)
    mail = RelationshipMailer.follow_notification(user, follower)
    assert_equal "#{follower.name} started following you", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["postmaster@sandboxffe2db8b555f4ccb8bd5d9b69d91962c.mailgun.org"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match follower.name, mail.body.encoded
  end

  test "unfollow_notification" do
    user = users(:archer)
    follower = users(:michael)
    mail = RelationshipMailer.unfollow_notification(user, follower)
    assert_equal "#{follower.name} unfollowed you", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["postmaster@sandboxffe2db8b555f4ccb8bd5d9b69d91962c.mailgun.org"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match follower.name, mail.body.encoded
  end
end