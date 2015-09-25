class User < ActiveRecord::Base
  serialize :credentials, Hash

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["display_name"]
      user.email = auth["info"]["email"]
      user.image_url = auth["info"]["images"].first["url"]
      user.credentials = auth
      user.access_token = auth["credentials"]["token"]
      user.refresh_token = auth["credentials"]["refresh_token"]
    end
  end
end
