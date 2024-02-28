# Use PHP/Apache base image
FROM php:8-apache

# Install dependencies 
RUN apt-get update && apt-get install -y

# Configure environment variables
ENV APP_ENV=dev 

# Copy application code to the container
COPY . /var/www/html 

# Set up config file for production
RUN if [ "$APP_ENV" = "prod" ]; then mv config.prod config; fi

# Expose the port used by Apache
EXPOSE 80
