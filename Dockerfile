FROM r-base:4.3.2 as builder

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages('tinytex')"

# Install TinyTeX
RUN Rscript -e 'tinytex::install_tinytex(force = TRUE)'

# Set TinyTeX path
ENV PATH="/root/.TinyTeX/bin/x86_64-linux:${PATH}"

# Verify TinyTeX installation and update
RUN /root/.TinyTeX/bin/x86_64-linux/tlmgr path add && \
    /root/.TinyTeX/bin/x86_64-linux/tlmgr update --self && \
    /root/.TinyTeX/bin/x86_64-linux/tlmgr update --all

# Install additional LaTeX packages
RUN /root/.TinyTeX/bin/x86_64-linux/tlmgr install \
    koma-script \
    caption \
    pgf \
    environ \
    tikzfill \
    tcolorbox \
    pdfcol

# Install Quarto
ENV QUARTO_VERSION="1.5.54"
RUN wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" && \
    dpkg -i quarto-${QUARTO_VERSION}-linux-amd64.deb && \
    apt-get update && apt-get install -f -y && \
    rm quarto-${QUARTO_VERSION}-linux-amd64.deb

WORKDIR /app

COPY . /app

RUN quarto render /app --output-dir /app/output

# Serve static files
FROM nginx:stable-alpine

COPY --from=builder /app/output /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
