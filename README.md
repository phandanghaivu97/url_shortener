# URL Shortener

A shortening service that creates short, shareable links from long URLs. This application provides a simple API to encode and decode URLs, with automatic redirection functionality.

## Features

- **URL Shortening**: Convert long URLs into short, 6-character alphanumeric identifiers generated using Rails built-in `SecureRandom` for unique ID generation, potential for collisions, but it makes the identifiers shorter and more *unpredictable*. This approach is suitable for current version, where security and unpredictability are prioritized over sequential ordering since the current implementation have not applied authentication.
- **URL Expansion**: Decode shortened URLs back to original URLs.
- **Data Compression**: Since URLs can be long, the original URLs are stored in a compressed format to save database space.
- **Duplicate Detection**: Using unique constraints on the compressed URL, let the database handle duplicate detection by itself. Handle conflicts gracefully by returning the existing URL.
- **Caching**: Utilize Redis to cache frequently accessed URLs for faster retrieval.
- **Collision Handling**: Handle potential identifier collisions by regenerating identifiers 3 times before returning an error.


## Url shortening flow
### 1. Shortening a URL
<img src="docs\img\url_shortening.png" alt="URL Shortening Flow" width="600"/>

### 2. Expanding a URL

<img src="docs\img\url_shortening_decoding.png" alt="URL Expanding Flow" width="600"/>

## Tech Stack

- **Backend**: Ruby on Rails 8.0.x
- **Database**: PostgreSQL
- **Caching**: Redis

## Demonstration
You can try it out by [clicking here](http://ec2-3-85-204-114.compute-1.amazonaws.com/).

## API Documentation

### Base URL
- Development: `http://localhost:3000`
- Production: Your deployed domain

### Endpoints

#### 1. Encode URL (Shorten)
Create a shortened URL from a long URL.

**Endpoint**: `POST /encode`

**Request Body**:
```json
{
  "original_url": "https://example.com/very/long/path/to/resource"
}
```

**Response** (201 Created):
```json
{
  "identifier": "abc123"
}
```

**Error Response** (422 Unprocessable Entity):
```json
{
  "errors": {
    "original_url": ["is invalid", "can't be blank"]
  }
}
```

**Example using curl**:
```bash
curl -X POST http://localhost:3000/encode \
  -H "Content-Type: application/json" \
  -d '{"original_url": "https://github.com/rails/rails"}'
```

#### 2. Decode URL (Expand)
Get the original URL from a shortened identifier.

**Endpoint**: `POST /decode`

**Request Body**:
```json
{
  "identifier": "abc123"
}
```

**Response** (201 Created):
```json
{
  "original_url": "https://example.com/very/long/path/to/resource"
}
```

**Example using curl**:
```bash
curl -X POST http://localhost:3000/decode \
  -H "Content-Type: application/json" \
  -d '{"identifier": "abc123"}'
```

#### 3. Direct Redirection
Navigate directly to a shortened URL to be redirected to the original URL.

**Endpoint**: `GET /:identifier`

**Response**: HTTP 302 Redirect to original URL

**Example**:
```
GET http://localhost:3000/abc123
→ Redirects to https://example.com/very/long/path/to/resource
```

## Installation & Setup

### Prerequisites
- Ruby 3.4.2
- PostgreSQL 12+
- Redis 6+
- Docker & Docker Compose (optional)

### Local Development

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd url_shortener
   ```

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Setup database**:
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Start Redis** (if not using Docker):
   ```bash
   redis-server
   ```

5. **Start the server**:
   ```bash
   rails server
   ```

6. **Visit the application**:
   Open `http://localhost:3000` in your browser

### Docker Development

1. **Start services**:
   ```bash
   docker-compose up
   ```

2. **Access the application**:
   Open `http://localhost:3000` in your browser

For detailed Docker instructions, see [DOCKER.md](DOCKER.md).

## Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
# Database Configuration
URL_SHORTENER_DATABASE_HOST=localhost
URL_SHORTENER_DATABASE_PORT=5432
URL_SHORTENER_DATABASE_USER=postgres
URL_SHORTENER_DATABASE_PASSWORD=your_password

# Redis Configuration
REDIS_URL=redis://localhost:6379/0

# Rails Configuration
RAILS_MASTER_KEY=your_master_key_here
RAILS_ENV=development
```

### Database Configuration

The application uses PostgreSQL. Configure your database settings in `config/database.yml` or use environment variables.

## Testing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/shortened_url_spec.rb
bundle exec rspec spec/controllers/home_controller_spec.rb

# Run with coverage
bundle exec rspec --format documentation

# Using Docker
docker-compose exec -e RAILS_ENV=test web bundle exec rspec
```

## Potential features:
- **Analytics**: Track usage statistics for shortened URLs.
- **User Accounts**: Allow users to authenticate their shortened URLs, by this way we can also applying another identifier generation strategy like Base62 encoding of an auto-incrementing ID.
- **Custom Aliases**: Enable users to create custom short URL identifiers.
- **Expiration**: Let authenticated users set expiration dates for their own shortened URLs.
- **Rate Limiting**: Prevent abuse by limiting the number of requests per user/IP, or using other services like Cloudflare.
- **Alerting**: Notify operators of suspicious activity such as potential abuse, security threats, identifier generator depletion, or other anomalies.
- ...and more!
