require "rails_helper"

RSpec.describe HomeController, type: :controller do
  let(:original_url) { "https://example.com" }

  describe "POST #encode" do
    context "when shortify the long url successfully" do
      it "creates a shortened url and returns json" do
        expect { post :encode, params: { original_url: } }.to change { ShortenedUrl.count }.by(1)

        created_shortened_url = ShortenedUrl.first

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["identifier"]).to eq(created_shortened_url.identifier)
      end
    end

    context "when url is invalid" do
      let(:original_url) { "invalid-url" }

      it "returns error" do
        expect { post :encode, params: { original_url: } }.not_to change { ShortenedUrl.count }
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq(["Original url is invalid"])
      end
    end

    context "when url is blank" do
      let(:original_url) { "" }

      it "returns error" do
        expect { post :encode, params: { original_url: } }.not_to change { ShortenedUrl.count }
        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to eq(["Original url can't be blank"])
      end
    end

    context "when unexpected error occur" do
      before do
        allow(ShortenedUrl).to receive(:shortify!).with(original_url).and_raise(StandardError, "Unexpected error")
        allow(Rails.logger).to receive(:error)
      end

      it "returns error" do
        expect { post :encode, params: { original_url: } }.not_to change { ShortenedUrl.count }
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("Something went wrong. Please try again!")
        expect(Rails.logger).to have_received(:error).with("HomeController#encode Encountered an error: Unexpected error")
      end
    end
  end

  describe "POST #decode" do
    let!(:shortened_url) {ShortenedUrl.shortify!(original_url)}

    before {allow(Rails.cache).to receive(:fetch).and_call_original}

    it "returns the original url from identifier" do
      post :decode, params: { identifier: shortened_url.identifier }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["original_url"]).to eq(original_url)
      expect(Rails.cache).to have_received(:fetch).with(["shortened_url", shortened_url.identifier], expires_in: 12.hours)
    end

    context "when identifier is invalid" do
      it "returns error" do
        post :decode, params: { identifier: "invalid-identifier" }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to eq("Shortened Url could not be found!")
      end
    end
  end

  describe "GET #show" do
    let!(:shortened_url) {ShortenedUrl.shortify!(original_url)}

    it "redirects to the original url" do
      get :show, params: { identifier: shortened_url.identifier }

      expect(response).to redirect_to("https://example.com")
    end

    context "when identifier is invalid" do
      it "returns error" do
        get :show, params: { identifier: "invalid-identifier" }

        expect(response).to redirect_to("/404")
      end
    end
  end
end
