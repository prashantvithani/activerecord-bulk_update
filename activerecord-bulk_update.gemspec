
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/bulk_update/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-bulk_update'
  spec.version       = Activerecord::BulkUpdate::VERSION
  spec.authors       = ['Prashant Vithani']
  spec.email         = ['prashantvithani@gmail.com']

  gem.summary        = 'Bulk update in single query'
  gem.description    = 'A library for updating multiple records in a single '\
                       'query using ActiveRecord'
  gem.homepage       = 'https://github.com/prashantvithani/activerecord-bulk_update'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing
  # to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against ' \
  #     'public gem pushes.'
  # end

  spec.require_paths = ['lib']
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'activerecord', '>= 3.2'
end
