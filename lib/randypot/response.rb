class Randypot
  class Response
    attr_reader :status, :content_type, :body, :etag
    def initialize(params)
      @status = params[:status]
      @content_type = params[:content_type]
      @body = params[:body]
      @etag = params[:etag]
    end

    def not_modified?
      status == 304
    end

    def success?
      (200..201).include? status
    end
  end
end
