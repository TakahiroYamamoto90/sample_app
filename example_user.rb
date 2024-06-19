class User
  attr_accessor :last_name, :first_name, :email

  def initialize(attributes = {})
    @last_name  = attributes[:last_name]
    @first_name  = attributes[:first_name]
    @email = attributes[:email]
  end

  def formatted_email
    "#{@last_name} #{@first_name} <#{@email}>"
  end

  def full_name
    "#{@first_name} #{@last_name}"
  end

  def alphabetical_name
    "#{@last_name}, #{@first_name}"
  end  
end