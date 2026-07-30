#!/bin/sh
# Substitui o placeholder {{POD_NAME}} pelo hostname real do container.
# No Kubernetes, o hostname do container é definido automaticamente
# com o nome do pod (ex: nginx-deployment-74c9594c85-zxtsl).
sed -i "s/{{POD_NAME}}/$HOSTNAME/g" /usr/share/nginx/html/index.html

# Repassa a execução para o comando original da imagem (nginx em foreground)
exec "$@"
