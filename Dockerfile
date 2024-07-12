FROM dereckmezquita/r-quarto-base:latest AS builder

WORKDIR /app

COPY . /app

# Render Quarto document
RUN quarto render /app --output-dir /app/output

# Serve static files
FROM nginx:stable-alpine AS runner

COPY --from=builder /app/output /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
