#!/bin/sh
# Substitui o placeholder {{POD_NAME}} pelo hostname real do container.
# No Kubernetes, o hostname do container é definido automaticamente
# com o nome do pod (ex: apache-deployment-6b9c8f7d4c-a1b2c).
sed -i "s/{{POD_NAME}}/$HOSTNAME/g" /usr/local/apache2/htdocs/index.html

# Repassa a execução para o comando original da imagem (httpd em foreground)
exec "$@"
