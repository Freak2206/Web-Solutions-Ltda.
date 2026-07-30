# Imagem base oficial do Apache HTTPD, na versão estável
FROM httpd:2.4-alpine

# Copia a página customizada da Web Solutions para o htdocs do Apache
COPY index.html /usr/local/apache2/htdocs/index.html

# Copia e habilita o script que injeta o nome do pod na página em tempo de execução
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Documenta a porta em que o container escuta internamente (Apache padrão = 80)
EXPOSE 80

# O entrypoint roda a substituição do hostname e depois inicia o Apache normalmente
ENTRYPOINT ["/entrypoint.sh"]
CMD ["httpd-foreground"]
