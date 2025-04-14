Je vais vous fournir quelques exemples de commandes curl pour tester votre API RestGREST sur différents endpoints. Ces exemples vous aideront à identifier si le problème vient de Swagger ou de votre API.
## OK

```bash
curl -X GET "https://postgrest.pocs.hachim.fr/api/categories" -H "Accept: application/json"
```

### Pour tester la récupération des catégories (GET)

```bash
# Récupérer toutes les catégories
curl -X GET "http://localhost:3000/categories" -H "Accept: application/json"

# Récupérer une catégorie spécifique par son ID
curl -X GET "http://localhost:3000/categories?id=eq.votre_uuid_de_categorie" -H "Accept: application/json"

# Récupérer les catégories de premier niveau (sans parent)
curl -X GET "http://localhost:3000/categories?parent_id=is.null" -H "Accept: application/json"
```

### Pour tester la récupération des quiz (GET)

```bash
# Récupérer tous les quiz publiés et publics
curl -X GET "http://localhost:3000/quizzes?status=eq.PUBLISHED&is_public=eq.true" -H "Accept: application/json"

# Récupérer un quiz spécifique par son ID
curl -X GET "http://localhost:3000/quizzes?id=eq.votre_uuid_de_quiz" -H "Accept: application/json"
```

### Pour tester l'authentification et les opérations protégées (POST)

```bash
# Obtenir un token JWT (si vous avez configuré votre fonction login)
curl -X POST "http://localhost:3000/rpc/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@quizapi.fr", "pass": "le_mot_de_passe"}'

# Créer une nouvelle catégorie (opération authentifiée)
curl -X POST "http://localhost:3000/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer votre_token_jwt" \
  -d '{"name": "Nouvelle Catégorie", "description": "Description de la catégorie"}'
```

### Pour tester les relations (GET)

```bash
# Récupérer les quiz avec leurs catégories associées
curl -X GET "http://localhost:3000/quizzes?select=id,title,description,category:categories(name)" -H "Accept: application/json"

# Récupérer les tags associés à un quiz spécifique
curl -X GET "http://localhost:3000/quiz_tags?quiz_id=eq.votre_uuid_de_quiz&select=quiz_id,tag:tags(*)" -H "Accept: application/json"
```

### Pour diagnostiquer les problèmes

```bash
# Vérifier l'état de l'API et les métadonnées
curl -X GET "http://localhost:3000/" -H "Accept: application/json"
```

### Notes importantes pour le dépannage

1. Vérifiez que le port 3000 est bien accessible depuis votre machine (c'est le port que PostgREST utilise selon votre configuration)

2. Si votre API est derrière un proxy Traefik comme indiqué dans votre docker-compose.yml, vous devriez aussi essayer les requêtes à travers ce proxy :
   ```bash
   curl -X GET "https://pocs.hachim.fr/api/categories" -H "Accept: application/json"
   ```

3. Vérifiez les paramètres CORS dans votre configuration PostgREST si vous accédez à l'API depuis un navigateur

4. Vérifiez les logs de votre container PostgreSQL et PostgREST pour voir s'il y a des erreurs:
   ```bash
   docker logs postgrest
   docker logs postgres
   ```

Si les requêtes curl fonctionnent mais que Swagger échoue, le problème pourrait être lié à la configuration de Swagger UI et à la façon dont il adresse votre API. Dans ce cas, vérifiez que l'URL de l'API configurée dans Swagger est correcte et accessible.