import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';
import { UserCircle, ArrowLeft } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

const FacultyLogin = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [credentials, setCredentials] = useState({ email: '', password: '' });

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/api/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          role: 'faculty',
          email: credentials.email,
          password: credentials.password,
        }),
      });

      if (response.ok) {
        const data = await response.json();
        localStorage.setItem('token', data.token);
        localStorage.setItem('user', JSON.stringify(data.user));
        
        toast({
          title: 'Login Successful',
          description: `Welcome ${data.user.name}!`,
        });
        navigate('/faculty/dashboard');
      } else {
        const error = await response.json();
        toast({
          title: 'Login Failed',
          description: error.error || 'Invalid credentials. Try: vidya@scem.ac.in / vidya123',
          variant: 'destructive',
        });
      }
    } catch (error) {
      console.error('Login error:', error);
      toast({
        title: 'Login Error',
        description: 'Network error. Please try again.',
        variant: 'destructive',
      });
    }
  };

  return (
    <div className="flex min-h-screen flex-col bg-gradient-to-br from-cyan-50 via-blue-50 to-indigo-100 dark:from-slate-900 dark:via-cyan-900 dark:to-slate-800">
      <Navbar />
      
      <main className="flex-1 flex items-center justify-center p-4">
        <div className="w-full max-w-md animate-scale-in">
          <Button
            variant="ghost"
            onClick={() => navigate('/')}
            className="mb-4 hover:bg-cyan-100 dark:hover:bg-cyan-800"
          >
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Home
          </Button>

          <Card className="shadow-ice border-ice bg-card/80 backdrop-blur-sm">
            <CardHeader className="text-center bg-gradient-to-br from-cyan-500/10 to-blue-500/10 rounded-t-lg">
              <div className="mx-auto mb-4 rounded-full bg-gradient-to-br from-cyan-100 to-blue-100 p-3 w-fit shadow-md">
                <UserCircle className="h-8 w-8 text-cyan-600" />
              </div>
              <CardTitle className="text-2xl">Faculty Login</CardTitle>
              <CardDescription>
                Enter your credentials to access the faculty portal
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleLogin} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input
                    id="email"
                    type="email"
                    placeholder="Enter email"
                    value={credentials.email}
                    onChange={(e) =>
                      setCredentials({ ...credentials, email: e.target.value })
                    }
                    required
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="password">Password</Label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="Enter password"
                    value={credentials.password}
                    onChange={(e) =>
                      setCredentials({ ...credentials, password: e.target.value })
                    }
                    required
                  />
                </div>
                <Button type="submit" className="w-full bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-600 hover:to-blue-600 text-white shadow-lg glow-ice">
                  Sign In
                </Button>
                <div className="text-xs text-center text-muted-foreground space-y-1 bg-gradient-to-r from-cyan-50 to-blue-50 dark:from-cyan-900/20 dark:to-blue-900/20 p-3 rounded-lg border border-ice">
                  <p><strong>Demo Credentials:</strong></p>
                  <p>vidya@scem.ac.in / vidya123</p>
                  <p>test@scem.ac.in / 123</p>
                  <p>demo@scem.ac.in / demo</p>
                  <p>faculty@scem.ac.in / faculty</p>
                  <p>ashwini@scem.ac.in / faculty123</p>
                </div>
              </form>
            </CardContent>
          </Card>
        </div>
      </main>

      <Footer />
    </div>
  );
};

export default FacultyLogin;
