class Randypot
  class Response
    attr_reader :status, :content_type, :body, :etag, :parsed
    def initialize(params)
      @status = params[:status]
      @content_type = params[:content_type]
      @body = params[:body]
      @etag = params[:etag]
      @parsed = ParsedMember.new(nil, 0, nil)
    end

    def parse(&block)
      @parsed = yield(@body)
    end

    def not_modified?
      status == 304
    end

    def success?
      (200..201).include? status
    end
  end
end
