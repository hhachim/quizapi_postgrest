```bash
curl -X 'POST' \
  'https://postgrest.pocs.hachim.fr:443/api/rpc/login' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "email": "user@example.com",
  "pass": "secure_password"
}'
```