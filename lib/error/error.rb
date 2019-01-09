module Error
  class CustomError < StandardError
    def initialize(message=I18n.t("errors.messages.#{self.class.name.demodulize}"))
      super
    end

    def hash_with_params(params={})
      {
        :error_class => self.class.name.demodulize,
        :message     => message,
        :status      => status
      }
    end

    def status; end
  end

  module Internal
    class UserExists < CustomError
      def status; :unauthorized end
    end

    class PasswordTooShort < CustomError
      def status; :unauthorized end
    end

    class InvalidAuthenticationToken < CustomError
      def status; :unauthorized end
    end
  end
end