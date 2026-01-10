FROM nginx

# Instalacao do stress
RUN apt-get update && \
    apt-get install -y stress && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copia o site estatico
COPY static_site /usr/share/nginx/html

# Copia a configuracao customizada do nginx
COPY default.conf /etc/nginx/conf.d/default.conf

# Copia o start.sh
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expoe porta 80
EXPOSE 80

# Executa o start.sh
CMD ["/start.sh"]