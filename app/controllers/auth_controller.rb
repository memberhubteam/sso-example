class AuthController < ActionController::API
  NAME = ENV.fetch('NAME', 'Partner Application')
  TOKEN = ENV.fetch('TOKEN', '78c26058-5c50-4a83-af17-62176c7cc13d')
  SECRET = ENV.fetch('SECRECT', '34ed46d9-a59a-4ab2-a46e-b53b7ef7a281')
  CLIENT = OAuth2::Client.new(
    TOKEN,
    SECRET,
    site: 'https://api.memberhub.dev',
    # NOTE: 'app' is the subdomain over the 'api' from above
    authorize_url: 'https://app.memberhub.dev/sso?service=partner',
    token_url: 'https://api.memberhub.dev/services/memberhub-service/users/me',
    token_method: :get # can be :get or :post
  )

  def create
    url = CLIENT.auth_code.authorize_url(redirect_uri: redirect_uri)

    redirect_to url
  end

  def update
    token = CLIENT.auth_code.get_token(
      params[:token],
      redirect_uri: redirect_uri,
      token: params[:token],
      uuid: params[:uuid],
      headers: {
        'MemberHub-Service' => NAME,
        'MemberHub-Service-Token' => TOKEN,
        'MemberHub-Service-Secret' => SECRET
      }
    )
    render json: {
      token: token.params.to_h.merge(
        token: token.token,
        refresh_token: token.refresh_token,
        expires_at: Time.at(token.expires_at).iso8601
      )
    }
    # NOTE: JSON response will be similar to:
    # {
    #   "token": {
    #     "uuid": "81d3ed96-8ac4-4deb-b911-ae1d34217a96",
    #     "user": {
    #       "email": "test@memberhub.com",
    #       "display": "test user",
    #       "first_name": "test",
    #       "last_name": "user",
    #       "confirmed": true,
    #       "uuid": "a3da4dc2-9f75-4ca7-8d93-e55aa7f98e21"
    #     },
    #     "token": "0c800dec-4c1c-4c00-a9a3-9566d012bcd3",
    #     "refresh_token": "2f10171b-2f60-4cf3-b231-801607060491",
    #     "expires_at": "2021-03-13T13:56:20-05:00"
    #   }
    # }
  end

  private

  def redirect_uri
    callback_url
  end
end
