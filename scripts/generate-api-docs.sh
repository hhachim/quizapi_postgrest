#!/bin/bash

# Variables
COLLECTION_FILE=${1:-"tests/postman/quiz-api-collection.json"}
OUTPUT_DIR="docs/api"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# Créer le répertoire de sortie s'il n'existe pas
mkdir -p "$OUTPUT_DIR"

echo "Génération de la documentation API à partir de la collection Postman..."

# Utiliser Docker pour générer la documentation
docker run --rm \
    -v "$(pwd)/$COLLECTION_FILE:/collection.json" \
    -v "$(pwd)/$OUTPUT_DIR:/output" \
    postman/newman:alpine sh -c '
    # Installer les dépendances
    apk add --no-cache nodejs npm git
    npm install -g postman-doc-gen

    # Générer la documentation
    postman-doc-gen -c /collection.json -o /output/index.html
    
    echo "Documentation générée dans /output/index.html"
    '

if [ $? -eq 0 ]; then
    echo "Documentation API générée avec succès dans $OUTPUT_DIR/index.html"
    
    # Créer un fichier README dans le répertoire de documentation
    cat > "$OUTPUT_DIR/README.md" << EOF
# Documentation API Quiz

Cette documentation est générée automatiquement à partir des collections Postman.

## Contenu

- **index.html**: Documentation interactive des endpoints API
- **openapi.yaml**: Spécification OpenAPI (si générée)
- **examples/**: Exemples de requêtes et réponses

## Comment utiliser cette documentation

1. Ouvrez \`index.html\` dans votre navigateur pour explorer l'API de manière interactive
2. Les exemples de code sont disponibles pour différents langages de programmation
3. Vous pouvez importer la spécification OpenAPI dans des outils comme Swagger UI

## Dernière mise à jour

Cette documentation a été générée le $(date +%Y-%m-%d) à $(date +%H:%M:%S).

## Maintenir la documentation à jour

Pour régénérer cette documentation après des modifications de l'API :

\`\`\`bash
./scripts/generate-api-docs.sh
\`\`\`
EOF

    echo "Documentation prête à être consultée!"
else
    echo "Erreur lors de la génération de la documentation."
    exit 1
fi