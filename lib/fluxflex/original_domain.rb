module Fluxflex
  module OriginalDomain
    mattr_accessor :default_domain, :original_domain

    def self.included(base)
      base.class_eval do
        alias_method_chain :process_request, :original_domain
      end
    end

    protected
      def process_request_with_original_domain(request)
        env = request.env

        if env['HTTP_HOST'] == default_domain
          env['HTTP_HOST'].replace(original_domain)
        end
        if env['SERVER_NAME'] == default_domain[/[^:]*/]
          env['SERVER_NAME'].replace(original_domain[/[^:]*/])
        end
        if env['REQUEST_URI']
          env['REQUEST_URI'].sub!(%r|\A(https?://)#{default_domain}/|) do
            "#{$1}#{original_domain}/"
          end
        end

        process_request_without_original_domain(request)
      end
  end
end

class RailsFCGIHandler
  include Fluxflex::OriginalDomain
end
