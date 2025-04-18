# Intégration des tests API avec le développement frontend

Ce document explique comment intégrer les tests Postman/Newman de l'API avec le processus de développement frontend.

## Workflow de développement intégré

1. **Tester l'API avant le développement frontend**
   - Exécuter les tests API pour vérifier que les endpoints sont opérationnels
   - Utiliser les résultats des tests pour documenter l'API pour les développeurs frontend

2. **Développer le frontend en se basant sur les contrats d'API vérifiés**
   - Utiliser les examples de requêtes et réponses des tests comme référence
   - S'assurer que le frontend respecte les formats de données attendus par l'API

3. **Tests d'intégration**
   - Tester le frontend avec l'API réelle
   - Utiliser les mêmes environnements Postman pour garantir la cohérence

## Scripts utilitaires pour le développement frontend

### Générer une documentation d'API basée sur Postman

```bash
# Générer une documentation pour les développeurs frontend
./scripts/generate-api-docs.sh
```

### Simuler l'API pour le développement frontend isolé

```bash
# Démarrer un mock server basé sur la collection Postman
docker run --rm -p 3000:3000 \
  -v "$(pwd)/tests/postman:/etc/newman" \
  postman/newman:alpine \
  run /etc/newman/quiz-api-collection.json --mock
```

## Utilisation avec React Query

[React Query](https://react-query.tanstack.com/) est recommandé pour la gestion d'état côté serveur dans votre application React. Voici comment l'intégrer avec l'API testée par Postman :

```javascript
// src/hooks/useQuizzes.js
import { useQuery, useMutation, useQueryClient } from 'react-query';
import axios from 'axios';

// Client API configuré
const apiClient = axios.create({
  baseURL: process.env.REACT_APP_API_URL || 'http://localhost:3000',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Hooks pour les quizzes
export const useQuizzes = (filters = {}) => {
  // Construire la requête avec les mêmes filtres que dans les tests Postman
  const queryString = Object.entries(filters)
    .map(([key, value]) => `${key}=${encodeURIComponent(value)}`)
    .join('&');

  return useQuery(['quizzes', filters], async () => {
    const response = await apiClient.get(`/quizzes?${queryString}`);
    return response.data;
  });
};

export const useQuiz = (id) => {
  return useQuery(['quiz', id], async () => {
    const response = await apiClient.get(`/quizzes?id=eq.${id}`);
    return response.data[0];
  }, {
    enabled: !!id,
  });
};

export const useCreateQuiz = () => {
  const queryClient = useQueryClient();
  
  return useMutation(
    async (quizData) => {
      const response = await apiClient.post('/quizzes', quizData, {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('token')}`,
        },
      });
      return response.data;
    },
    {
      onSuccess: () => {
        // Invalider et rafraîchir les requêtes qui dépendent des quizzes
        queryClient.invalidateQueries('quizzes');
      },
    }
  );
};
```

## Validation des types de données

Pour garantir que le frontend respecte les formats attendus par l'API, utilisez des bibliothèques de validation :

```javascript
// src/validators/quizValidator.js
import * as yup from 'yup';

// Schéma de validation qui correspond aux attentes de l'API
export const quizSchema = yup.object({
  title: yup.string().required('Le titre est requis').max(255),
  description: yup.string(),
  difficulty_level: yup.string()
    .oneOf(['BEGINNER', 'EASY', 'MEDIUM', 'HARD', 'EXPERT'], 'Niveau de difficulté invalide'),
  time_limit: yup.number().nullable().integer('Doit être un nombre entier'),
  passing_score: yup.number().nullable().min(0).max(100),
  status: yup.string()
    .oneOf(['DRAFT', 'PUBLISHED', 'ARCHIVED', 'REVIEWING'], 'Statut invalide')
    .default('DRAFT'),
  is_public: yup.boolean().default(false),
  category_id: yup.string().uuid('ID de catégorie invalide').nullable(),
});
```

## Mode de développement avec Mock API

Pour développer le frontend sans dépendre d'une API en cours d'exécution :

```jsx
// src/contexts/ApiContext.jsx
import React, { createContext, useState, useContext } from 'react';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import quizzesMockData from '../mocks/quizzes.json';

const ApiContext = createContext();

export const ApiProvider = ({ children, useMocks = false }) => {
  const [client] = useState(() => {
    const axiosInstance = axios.create({
      baseURL: process.env.REACT_APP_API_URL || 'http://localhost:3000',
    });

    // Configurer les mocks si nécessaire (basés sur les exemples Postman)
    if (useMocks) {
      const mock = new MockAdapter(axiosInstance);
      
      // Simuler les réponses d'API basées sur les collections Postman
      mock.onGet('/quizzes').reply(200, quizzesMockData);
      mock.onGet(/\/quizzes\?id=eq\..+/).reply((config) => {
        const id = config.url.match(/id=eq\.(.+)/)[1];
        const quiz = quizzesMockData.find(q => q.id === id);
        return [200, quiz ? [quiz] : []];
      });
      // Autres mocks basés sur les tests Postman...
    }

    return axiosInstance;
  });

  return (
    <ApiContext.Provider value={{ client }}>
      {children}
    </ApiContext.Provider>
  );
};

export const useApi = () => useContext(ApiContext);
```

## Genération de mocks à partir des collections Postman

Les exemples de réponses des collections Postman peuvent être utilisés pour générer des données mock :

```bash
# Extraire les exemples de réponses des collections Postman
jq '.item[].item[].response[].body.raw' tests/postman/quiz-api-collection.json | \
  grep -v null | \
  jq -s '.' > src/mocks/api-responses.json
```

Cette approche garantit que vos mocks frontend correspondent exactement aux données réelles de l'API, validées par vos tests automatisés.

## Conseils pour un développement efficace

1. **Versionnement des tests et de l'API** : Assurez-vous que les tests Postman sont mis à jour en même temps que les modifications de l'API.

2. **Développement TDD** : Écrivez d'abord les tests Postman pour définir le comportement attendu de l'API avant l'implémentation.

3. **Tests parallèles** : Exécutez les tests Postman dans le cadre du pipeline CI/CD pour vérifier que le frontend et l'API restent compatibles.

4. **Documentation vivante** : Utilisez les collections Postman comme source unique de vérité pour la documentation d'API.