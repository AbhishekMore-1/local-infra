# local-infra

Docker compose for setting up local infra

## Builds behind a TLS-intercepting proxy (Zscaler)

Image builds that fetch packages (e.g. `postgres/postgis.Dockerfile`) fail with
`server certificate not trusted` while Zscaler is on. Pass its root CA as the
optional `corp_ca` build secret on the first `up` (or any rebuild):

```sh
mkdir -p .certs
security find-certificate -c "Zscaler Root CA" -p /Library/Keychains/System.keychain > .certs/corp-ca.pem
CORP_CA_PEM="$(cat .certs/corp-ca.pem)" just up postgres postgis
```

`.certs/` is gitignored. Without `CORP_CA_PEM` the build runs unchanged.