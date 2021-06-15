require "semantic_range"
namespace :webpacker do
  desc "Verifies if Yarn is installed"
  task :check_yarn do
    begin
      which_command = Gem.win_platform? ? "where" : "which"
      raise Errno::ENOENT if `#{which_command} yarn`.strip.empty?

      yarn_version = `yarn --version`.strip
      raise Errno::ENOENT if yarn_version.blank?

      pkg_path = Pathname.new("#{__dir__}/../../../package.json").realpath
      yarn_range = SemanticRange.valid_range(JSON.parse(pkg_path.read)["engines"]["yarn"], loose: true)

      # NOTE: pre/rc versions aren't well supported in semantic range right now.
      # is_valid = SemanticRange.satisfies?(yarn_version, yarn_range, loose: true) # rescue false

      is_valid = SemanticRange.gt?(yarn_version, "1.0.0") rescue false
      is_unsupported = SemanticRange.satisfies?(yarn_version, ">=4.0.0") rescue false

      unless is_valid
        $stderr.puts "Webpacker requires Yarn \"#{yarn_range}\" and you are using #{yarn_version}"
        if is_unsupported
          $stderr.puts "This version of Webpacker does not support Yarn #{yarn_version}. Please downgrade to a supported version of Yarn https://yarnpkg.com/lang/en/docs/install/"
        else
          $stderr.puts "Please upgrade Yarn https://yarnpkg.com/lang/en/docs/install/"
        end
        $stderr.puts "Exiting!"
        exit!
      end
    rescue Errno::ENOENT
      $stderr.puts "Yarn not installed. Please download and install Yarn from https://yarnpkg.com/lang/en/docs/install/"
      $stderr.puts "Exiting!"
      exit!
    end
  end
end
