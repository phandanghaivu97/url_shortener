# Docker Setup for URL Shortener

## Files Overview

- `docker-compose.yml` - Main compose file with PostgreSQL and Redis
- `Dockerfile` - Main Dockerfile


## Development Setup

1. **Start development services:**
   ```bash
   docker-compose up
   ```
   This starts:
   - PostgreSQL on port 5432
   - Redis on port 6379
   - Rails app on port 3000

2. **Run tests:**
   ```bash
   docker-compose exec web bundle exec rspec
   ```

### Development
```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f web

# Run tests
docker-compose exec -e RAILS_ENV=test web bundle exec rspec
```

### Cleanup
```bash
# Stop and remove containers
docker-compose down

# Remove volumes (WARNING: This deletes database data)
docker-compose down -v

# Remove everything including images
docker-compose down -v --rmi all
```

## Ports

- **3000**: Rails application
- **5432**: PostgreSQL
- **6379**: Redis

## Volumes

- `postgres_data`: PostgreSQL database files
- `redis_data`: Redis data files
- `bundle_cache`: Bundler gem cache for faster rebuilds
