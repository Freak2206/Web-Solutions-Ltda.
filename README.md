# Web Solutions — Orquestração de Containers com Kubernetes

Prova de conceito desenvolvida para o desafio da **Web Solutions Ltda.**, demonstrando a coexistência de dois servidores web distintos — **Nginx** e **Apache HTTPD** — em um ambiente containerizado e orquestrado pelo **Kubernetes**.

## O Problema

A Web Solutions hospeda suas aplicações diretamente em máquinas virtuais. Com o crescimento da demanda, esse modelo se tornou um gargalo: alocação de recursos inflexível, escalabilidade manual e lenta, e conflitos de dependências entre ambientes — tudo isso impactando o tempo de resposta para novas implantações.

A solução identificada foi migrar para **containers (Docker)** orquestrados por **Kubernetes**, começando por uma prova de conceito: colocar dois servidores web diferentes rodando lado a lado, de forma independente, no mesmo cluster.

## Requisitos Atendidos

| Requisito | Como foi resolvido |
|---|---|
| Imagens Docker otimizadas | Bases `alpine` (leves): Nginx ~73 MB, Apache ~96 MB |
| Deployments e Services Kubernetes | 1 Deployment + 1 Service por servidor (4 manifestos YAML) |
| Nginx exposto na porta 8080 | `nginx-service` (NodePort) → porta interna 80 |
| Apache HTTPD exposto na porta 8081 | `apache-service` (NodePort) → porta interna 80 |
| Escalabilidade independente | Cada servidor tem seu próprio Deployment; `kubectl scale` afeta só um dos dois |
| Persistência de dados | Não implementada — decisão justificada abaixo |
| Documentação do processo | Este README + PDF conceitual sobre YAML |

## Arquitetura

```
web-solutions-k8s/
├── nginx/
│   ├── Dockerfile          # imagem baseada em nginx:1.27-alpine
│   ├── entrypoint.sh       # injeta o nome do pod na página em runtime
│   └── index.html          # página customizada com placeholder {{POD_NAME}}
├── apache/
│   ├── Dockerfile          # imagem baseada em httpd:2.4-alpine
│   ├── entrypoint.sh       # injeta o nome do pod na página em runtime
│   └── index.html          # página customizada com placeholder {{POD_NAME}}
└── k8s/
    ├── nginx-deployment.yaml    # 2 réplicas do Nginx
    ├── nginx-service.yaml       # expõe porta 8080
    ├── apache-deployment.yaml   # 2 réplicas do Apache
    └── apache-service.yaml      # expõe porta 8081
```

Cada servidor segue o mesmo pipeline, de forma independente:

**Dockerfile → Imagem Docker → Deployment (2 pods) → Service (porta fixa)**

## Como Executar

Pré-requisitos: [Docker Desktop](https://www.docker.com/products/docker-desktop/), [minikube](https://minikube.sigs.k8s.io/docs/start/) e `kubectl` (ou use `minikube kubectl --`).

```bash
# 1. Subir o cluster local
minikube start

# 2. Construir as imagens dentro do minikube
minikube image build -t web-solutions/nginx:1.0 ./nginx
minikube image build -t web-solutions/apache:1.0 ./apache

# 3. Aplicar os manifestos
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/nginx-service.yaml
kubectl apply -f k8s/apache-deployment.yaml
kubectl apply -f k8s/apache-service.yaml

# 4. Verificar que os pods estão de pé
kubectl get pods
kubectl get svc

# 5. Acessar cada serviço (mantenha o terminal aberto durante o uso)
minikube service nginx-service --url
minikube service apache-service --url
```

## Balanceamento de Carga

Cada página exibe o nome do pod que respondeu à requisição (via variável de ambiente `HOSTNAME`, definida automaticamente pelo Kubernetes). Como cada serviço tem 2 réplicas, é possível observar o `Service` alternando o tráfego entre os pods — evidência direta do balanceamento de carga do Kubernetes.

> Atenção: navegadores costumam manter a conexão TCP aberta (keep-alive) entre requisições, então dar F5 na mesma aba pode não mostrar a alternância. Para forçar conexões novas via terminal (PowerShell):
> ```powershell
> for ($i=0; $i -lt 8; $i++) {
>   $r = Invoke-WebRequest "http://127.0.0.1:PORTA" -DisableKeepAlive
>   ($r.Content -match 'pod: <code>(.*?)</code>') | Out-Null
>   $matches[1]
> }
> ```

## Sobre Persistência de Dados

O conteúdo servido por ambos os containers é estático e embutido na própria imagem Docker durante o build — não há dados gerados em tempo de execução que precisem sobreviver a uma reinicialização do pod. Por isso, o uso de `PersistentVolume`/`PersistentVolumeClaim` não foi implementado nesta prova de conceito, alinhado ao próprio enunciado do desafio, que classifica esse requisito como não estritamente necessário para este cenário.

Caso a Web Solutions hospede futuramente aplicações com dados dinâmicos (uploads, sessões, logs), a expansão natural seria declarar um `PersistentVolumeClaim` e montá-lo no diretório servido pelo container (`/usr/share/nginx/html` no Nginx, `/usr/local/apache2/htdocs` no Apache).

## Próximos Passos / Expansão

- Migrar outras aplicações da Web Solutions para o mesmo padrão de Deployment + Service.
- Trocar `NodePort` por `Ingress` para expor múltiplos serviços por domínio/caminho em produção.
- Adicionar `PersistentVolumeClaim` para aplicações com dados dinâmicos.
- Configurar `HorizontalPodAutoscaler` para escalar automaticamente com base em uso de CPU/memória.

## Tecnologias

- Docker
- Kubernetes (testado em minikube)
- Nginx (alpine) e Apache HTTPD (alpine)
- YAML (Deployments e Services)
