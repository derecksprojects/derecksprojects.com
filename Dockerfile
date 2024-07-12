# https://github.com/quarto-dev/quarto-cli/discussions/2050
FROM node:18-alpine AS base

COPY . /app

# set quarto version here as env var
ENV QUARTO_VERSION="1.5.54"

RUN apt-get update \ 
  && apt-get -y install wget ca-certificates \
  && wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-arm64.deb" -O quarto.deb \
  && dpkg -i quarto.deb

RUN quarto install tinytex

RUN quarto render /app --output-dir /usr/share/nginx/html

FROM nginx:latest

COPY --from=build /usr/share/nginx/html /usr/share/nginx/html

EXPOSE 80
