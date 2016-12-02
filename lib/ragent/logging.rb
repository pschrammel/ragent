module Ragent
  module Logging
  def debug str
    @logger.debug(str)
  end

  def warn str
    @logger.warn(str)
  end

  def info str
    @logger.info(str)
  end

  def error str
    @logger.error(str)
  end
  end
end
