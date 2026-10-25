# Ghost Helm Chart

This Helm chart deploys Ghost CMS (version 6) with ActivityPub support and a MySQL database on Kubernetes.

## Features

-   Modern Ghost 6 deployment with persistent storage
-   ActivityPub federation support for social publishing
-   MySQL database with initialization scripts and multiple database support
-   Kubernetes Secrets for sensitive data
-   Configurable ingress with ActivityPub routing

This helm chart was created with Kompose and heavily edited with help from Claude. This is not a recommended deployment method from Ghost, but I have my own k8 cloud hosted locally and I wanted the automatic let's encrypt support I get through an nginx ingress. This deployment is working great so far for me for a couple of sites, and I hope it provides a good starting point for someone else as well.

## Installation

```bash
# Install with custom values
helm install my-ghost ./ghost-helm -f custom-values.yaml

# Upgrade deployment
helm upgrade my-ghost ./ghost-helm -f custom-values.yml
```

## Configuration

### Secrets

The chart stores sensitive data in Kubernetes Secrets:

-   Database passwords (root and user)
-   Mail authentication credentials

### Values Configuration

Key configuration options in `values.yaml`:

```yaml
# Ghost configuration
ghost:
    domain: "your-domain.com"
    adminUrl: "https://admin.your-domain.com"
    url: "https://your-domain.com"

# ActivityPub configuration
activitypub:
    enabled: true
    version: "1.1"
    port: 8080
    allowPrivateAddress: true

# Database configuration
database:
    name: "ghost"
    user: "ghost"
    multipleDatabases: "activitypub" # Additional database for ActivityPub

# Secrets (store securely)
secrets:
    database:
        password: "your-db-password"
        rootPassword: "your-root-password"
    mail:
        auth:
            user: "your-smtp-user"
            password: "your-smtp-password"
```

## Services Deployed

This chart deploys the following Kubernetes services:

-   **Ghost CMS** (port 2368) - Main Ghost application
-   **ActivityPub** (port 8080) - Federation service (when enabled)
-   **MySQL Database** (port 3306) - Database backend

It does not currently deploy any of the tinybird analytics.

## Persistent Storage

The chart creates PersistentVolumeClaims for:

-   Ghost content data (20Gi by default) - shared between Ghost and ActivityPub - This needs to be ReadWriteMany due to the way Ghost has built the services
-   MySQL data (8Gi by default)

Storage sizes can be configured in `values.yaml`.

## Mail Configuration

Configure SMTP settings in the `secrets.mail` section of `values.yaml` for Ghost to send emails.

## Ingress and Routing

The chart includes an ingress configuration that handles both Ghost and ActivityPub routing:

-   Ghost content is served from the root path (`/`)
-   ActivityPub federation endpoints are automatically routed:
    -   `/.ghost/activitypub/*` - ActivityPub API endpoints
    -   `/.well-known/webfinger` - WebFinger discovery
    -   `/.well-known/nodeinfo` - NodeInfo protocol

The ingress supports both the main domain and admin domain with proper SSL termination.

### Static `.well-known` files

Set `staticFiles.enabled` and provide a list of files to serve a manifest without
passing it through Ghost. Each file is rendered into a ConfigMap, mounted into a
small nginx Deployment, and routed by an exact path on the public Ghost domain.

```yaml
staticFiles:
  enabled: true
  files:
    - name: apple-app-site-association
      path: /.well-known/apple-app-site-association
      contentType: application/json
      content: |
        {"applinks":{"apps":[]}}
```

Do not configure `/.well-known/webfinger` or `/.well-known/nodeinfo` while
ActivityPub is enabled; those routes remain owned by the ActivityPub service.

## Customization

You can customize the deployment by modifying `values.yaml` or creating your own values file with overrides.
