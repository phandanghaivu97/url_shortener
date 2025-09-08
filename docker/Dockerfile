# Development Dockerfile
FROM ruby:3.4.2-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libjemalloc2 \
    libyaml-dev \
    pkg-config \
    postgresql-client \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set working directory
WORKDIR /rails

# Set environment variables
ENV RAILS_ENV=development \
    BUNDLE_PATH="/usr/local/bundle"

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the application
COPY . .

# Copy and setup entrypoint script (as root)
COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Create a non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails

USER rails

ENTRYPOINT ["entrypoint.sh"]

# Expose port
EXPOSE 3000

# Start server
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
