import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

// Types
type User = {
  id: string;
  username: string;
  email: string;
  role: string;
};

type AuthContextType = {
  user: User | null;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
};

// Initial context state
const defaultAuthContext: AuthContextType = {
  user: null,
  isLoading: false,
  error: null,
  login: async () => {},
  logout: () => {},
  isAuthenticated: false,
};

// Create context
const AuthContext = createContext<AuthContextType>(defaultAuthContext);

// Context provider component
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Check if user is already logged in
  useEffect(() => {
    const checkUserLoggedIn = async () => {
      try {
        // Check for token in localStorage
        const token = localStorage.getItem('auth_token');
        
        if (token) {
          // For now, let's just assume there's a valid user if token exists
          // In a real app, validate the token with your API
          const userData = JSON.parse(localStorage.getItem('user') || '{}');
          setUser(userData);
        }
      } catch (error) {
        console.error('Authentication error:', error);
      } finally {
        setIsLoading(false);
      }
    };

    checkUserLoggedIn();
  }, []);

  // Login function
  const login = async (email: string, password: string) => {
    setIsLoading(true);
    setError(null);
    
    try {
      // In a real application, you would make a call to your API here
      // For now, let's create a mock login for demonstration
      
      // Replace with actual API call
      // const response = await fetch('https://postgrest.pocs.hachim.fr/api/rpc/login', {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify({ email, password }),
      // });
      
      // if (!response.ok) {
      //   throw new Error('Invalid credentials');
      // }
      
      // const data = await response.json();
      
      // Mock successful login response
      const mockSuccessfulLogin = email === 'admin@quizapi.fr' && password === 'password123';
      
      if (!mockSuccessfulLogin) {
        throw new Error('Invalid credentials');
      }
      
      // Mock user data and token
      const mockUserData: User = {
        id: '1',
        username: 'admin',
        email: 'admin@quizapi.fr',
        role: 'admin',
      };
      
      const mockToken = 'mock-jwt-token';
      
      // Save user data and token
      localStorage.setItem('auth_token', mockToken);
      localStorage.setItem('user', JSON.stringify(mockUserData));
      
      // Update context state
      setUser(mockUserData);
      
    } catch (error: any) {
      setError(error.message || 'An error occurred during login');
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  // Logout function
  const logout = () => {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user');
    setUser(null);
  };

  // Value object to provide to consumers
  const value = {
    user,
    isLoading,
    error,
    login,
    logout,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// Custom hook to use the auth context
export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  
  return context;
};