import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';
import { GraduationCap, ArrowLeft } from 'lucide-react';
import { useToast } from '@/hooks/use-toast';

const StudentLogin = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [credentials, setCredentials] = useState({ usn: '', password: '' });

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const res = await fetch(`${import.meta.env.VITE_API_URL}/api/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ role: 'student', usn: credentials.usn, password: credentials.password }),
      });
      const data = await res.json();
      
      if (!res.ok || data.success === false || data.message === 'Offline') {
        throw new Error(data.error || data.message || 'Login failed');
      }
      
      if (!data.token || !data.user) {
        throw new Error('Invalid response from server');
      }
      
      localStorage.setItem('token', data.token);
      localStorage.setItem('user', JSON.stringify(data.user));
      
      toast({ title: 'Login Successful', description: 'Welcome to Student Portal' });
      
      // Small delay to ensure localStorage is set
      setTimeout(() => {
        navigate('/student/dashboard');
      }, 100);
      
    } catch (err: unknown) {
      const error = err as Error;
      console.error('Login error:', error);
      toast({ title: 'Login Failed', description: error.message || 'Invalid credentials', variant: 'destructive' });
    }
  };

  return (
    <div className="flex min-h-screen flex-col bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-100 dark:from-slate-900 dark:via-indigo-900 dark:to-slate-800">
      <Navbar />
      
      <main className="flex-1 flex items-center justify-center p-4">
        <div className="w-full max-w-md animate-scale-in">
          <Button
            variant="ghost"
            onClick={() => navigate('/')}
            className="mb-4 hover:bg-indigo-100 dark:hover:bg-indigo-800"
          >
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Home
          </Button>

          <Card className="shadow-ice border-ice bg-card/80 backdrop-blur-sm">
            <CardHeader className="text-center bg-gradient-to-br from-indigo-500/10 to-purple-500/10 rounded-t-lg">
              <div className="mx-auto mb-4 rounded-full bg-gradient-to-br from-indigo-100 to-purple-100 p-3 w-fit shadow-md">
                <GraduationCap className="h-8 w-8 text-indigo-600" />
              </div>
              <CardTitle className="text-2xl">Student Login</CardTitle>
              <CardDescription>
                Enter your USN and password to access the student portal
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleLogin} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="usn">USN</Label>
                  <Input
                    id="usn"
                    type="text"
                    placeholder="Enter USN"
                    value={credentials.usn}
                    onChange={(e) =>
                      setCredentials({ ...credentials, usn: e.target.value })
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
                <Button type="submit" className="w-full bg-gradient-to-r from-indigo-500 to-purple-500 hover:from-indigo-600 hover:to-purple-600 text-white shadow-lg glow-ice">
                  Sign In
                </Button>
                <p className="text-xs text-center text-muted-foreground bg-gradient-to-r from-indigo-50 to-purple-50 dark:from-indigo-900/20 dark:to-purple-900/20 p-3 rounded-lg border border-ice">
                  Demo: USN 4SC21CS001 / student123
                </p>
              </form>
            </CardContent>
          </Card>
        </div>
      </main>

      <Footer />
    </div>
  );
};

export default StudentLogin;
