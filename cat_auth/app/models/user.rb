# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord

    validates :username, presence: true, uniqueness: true
    validates :session_token, presence: true, uniqueness: true
    validates :password_digest, presence: { message: 'password cant be blank' }
    validates :password, length: { minimum: 6 }, allow_nil: true

    after_initialize :ensure_session_token # ask about difference with befroe_validates

    attr_reader :password

    def self.generate_session_token
        SecureRandom::urlsafe_base64
    end

    def reset_session_token!
        self.session_token = User.generate_session_token
        self.save!
        self.session_token

        # self.update({ session_token: self.class.generate_session_token})
    end

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
        # can BCrypt.Password.create(password) also work
    end

    def is_password?(password)
        bcrypt_password = BCypt::Password.new(self.password_digest)
        bcrypt_password.is_password?(password)

        # BCrypt::Password.new(user.password_digest).is_password?(password)
    end

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)
        return nil unless user && user.is_password?(password)
        user

        # return user unless self.username == username && BCrypt::Password.new(password)
    end

end
