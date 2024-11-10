module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end

    private

    def find_verified_user
      # Extract the token from the query params
      token = request.params[:token]
      puts "token: #{token}"

      # Validate the token, e.g., by looking up the user associated with it
      # (replace `User.find_by(token: token)` with your actual verification logic)
      # User.find_by(auth_token: token)
      nil
    rescue ActiveRecord::RecordNotFound
      puts "token22"
      # Return nil if token is invalid or user is not found
      nil
    end
  end
end
