# Kong IP Header Restriction

A kong plugin to create a whitelist or blacklist by forwarded IP on headers 
(like: "x-forwarded-for", "x-real-ip", ...).

# Why?

If you use load balancers or cloudflare, request will be proxied then your client request IP will be placed on a header, there is a Kong core plugin called IP Restriction, this plugin check IP from Nginx context. 

# Testing

First of all up docker containers for tests:

```bash
docker-compose up -d
```

```bash
# allowed request
curl --location --request GET 'http://localhost:8000' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--header 'X-Forwarded-For: 127.0.0.1' \
--data-raw ''

# request blocked
curl --location --request GET 'http://localhost:8000' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--header 'X-Forwarded-For: 127.0.0.2' \
--data-raw ''

# {"message":"Your IP address is not allowed"}%  
```