# Imagem base oficial do Nginx, na versão estável e leve (alpine)
FROM nginx:1.27-alpine

# Remove a página padrão do Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copia a página customizada da Web Solutions para o diretório servido pelo Nginx
COPY index.html /usr/share/nginx/html/index.html

# Copia e habilita o script que injeta o nome do pod na página em tempo de execução
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Documenta a porta em que o container escuta internamente (Nginx padrão = 80)
EXPOSE 80

# O entrypoint roda a substituição do hostname e depois inicia o Nginx normalmente
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
