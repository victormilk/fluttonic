# Stage 1 - Install dependencies
FROM debian as builder

# Install dependencies
RUN apt update
RUN apt install -y curl git wget unzip
RUN apt clean

# Install flutter sdk
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Add flutter to path
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor
# Enable web support
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Stage 2 - Build app
FROM builder as app_builder
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN flutter clean
RUN flutter pub get
RUN flutter build web

# Stage 3 - Serve app
FROM nginx:alpine
COPY --from=app_builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]