 ```bash
 curl -X POST "http://172.19.0.4:3000/rpc/register"   -H "Content-Type: application/json"   -d '{"username": "newuser", "email": "user@example.com", "pass": "secure_password", "first_name": "John", "last_name": "Doe"}'
 ```