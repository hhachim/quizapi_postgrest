import apiClient from '../lib/postgrest';
import Cookies from 'js-cookie';

const TOKEN_NAME = 'jwt_token';

interface LoginResponse {
  success: boolean;
  token?: string;
  error?: string;
}

interface RegisterData {
  username: string;
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}

interface UserResponse {
  success: boolean;
  user?: {
    id: string;
    username: string;
    email: string;
    first_name: string;
    last_name: string;
  };
  error?: string;
}

export const login = async (email: string, password: string): Promise<LoginResponse> => {
  try {
    const response = await apiClient.post('/rpc/login', {
      email,
      pass: password
    });
    
    if (response.data && typeof response.data === 'string') {
      Cookies.set(TOKEN_NAME, response.data, { expires: 1 }); // Expire en 1 jour
      return { success: true, token: response.data };
    } else {
      return { success: false, error: 'Invalid response format' };
    }
  } catch (error: any) {
    return { 
      success: false, 
      error: error.response?.data || 'Authentication failed' 
    };
  }
};

export const register = async (userData: RegisterData): Promise<LoginResponse> => {
  try {
    const response = await apiClient.post('/rpc/register', {
      username: userData.username,
      email: userData.email,
      pass: userData.password,
      first_name: userData.firstName,
      last_name: userData.lastName
    });
    
    if (response.data && typeof response.data === 'string') {
      Cookies.set(TOKEN_NAME, response.data, { expires: 1 }); // Expire en 1 jour
      return { success: true, token: response.data };
    } else {
      return { success: false, error: 'Invalid response format' };
    }
  } catch (error: any) {
    return { 
      success: false, 
      error: error.response?.data || 'Registration failed' 
    };
  }
};

export const logout = (): void => {
  Cookies.remove(TOKEN_NAME);
  if (typeof window !== 'undefined') {
    window.location.href = '/auth/login';
  }
};

export const getCurrentUser = async (): Promise<UserResponse> => {
  try {
    const response = await apiClient.get('/users?select=id,username,email,first_name,last_name&id=eq.current');
    if (response.data && response.data.length > 0) {
      return { success: true, user: response.data[0] };
    } else {
      return { success: false, error: 'User not found' };
    }
  } catch (error) {
    return { success: false, error: 'Failed to fetch user data' };
  }
};

export const isAuthenticated = (): boolean => {
  return !!Cookies.get(TOKEN_NAME);
};
