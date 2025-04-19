// src/services/authService.ts
import axios from 'axios';

// Créer une instance Axios pour PostgREST avec des configurations par défaut
const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'https://postgrest.pocs.hachim.fr/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Intercepteur pour ajouter le token JWT aux requêtes
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interface pour les infos utilisateur
export interface User {
  id: string;
  email: string;
  username: string;
  role: string;
}

// Interface pour les données de login
export interface LoginData {
  email: string;
  pass: string;
}

// Interface pour les données d'inscription
export interface RegisterData {
  email: string;
  username: string;
  password: string;
  first_name?: string;
  last_name?: string;
}

// Interface pour la réponse de login
export interface LoginResponse {
  token: string;
  user: User;
}

// Fonction pour se connecter
export const login = async (credentials: LoginData): Promise<LoginResponse> => {
  try {
    // En mode développement/test, si vous voulez court-circuiter l'API
    if (process.env.NODE_ENV === 'development' && credentials.email === 'admin@quizapi.fr') {
      const mockResponse: LoginResponse = {
        token: 'mock-jwt-token',
        user: {
          id: '1',
          email: credentials.email,
          username: 'admin',
          role: 'admin',
        },
      };
      return mockResponse;
    }

    // Appel API réel
    const response = await apiClient.post('/rpc/login', credentials);
    return response.data;
  } catch (error) {
    console.error('Login error:', error);
    throw error;
  }
};

// Fonction pour s'inscrire
export const register = async (userData: RegisterData): Promise<User> => {
  try {
    const response = await apiClient.post('/rpc/register', userData);
    return response.data;
  } catch (error) {
    console.error('Register error:', error);
    throw error;
  }
};

// Fonction pour vérifier si l'utilisateur est authentifié
export const checkAuthStatus = async (): Promise<User | null> => {
  const token = localStorage.getItem('auth_token');
  if (!token) return null;

  try {
    // Dans un vrai cas, vous pourriez avoir un endpoint qui vérifie le token
    // et renvoie les infos utilisateur
    // const response = await apiClient.get('/me');
    // return response.data;
    
    // Pour l'instant, on récupère simplement l'utilisateur stocké
    const userData = localStorage.getItem('user');
    return userData ? JSON.parse(userData) : null;
  } catch (error) {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user');
    return null;
  }
};

// Fonction pour se déconnecter
export const logout = (): void => {
  localStorage.removeItem('auth_token');
  localStorage.removeItem('user');
};

export default {
  login,
  register,
  checkAuthStatus,
  logout,
};