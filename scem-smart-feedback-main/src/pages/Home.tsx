import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';
import Logo from '@/components/Logo';
import { ShieldCheck, UserCircle, GraduationCap } from 'lucide-react';

const Home = () => {
  const navigate = useNavigate();

  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />
      
      <main className="flex-1">
        {/* Hero Section */}
        <section className="relative h-[500px] w-full overflow-hidden">
          <img
            src="https://data.sahyadri.edu.in/main/gallery/campus/4.jpg"
            alt="Sahyadri Campus"
            className="h-full w-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-br from-blue-900/80 via-cyan-800/60 to-indigo-900/70">
            <div className="container flex h-full flex-col justify-center">
              <div className="max-w-2xl space-y-6 animate-slide-up">
                <div className="flex items-center gap-4">
                  <Logo size="xl" />
                </div>
                <h1 className="text-5xl font-bold leading-tight text-white drop-shadow-lg">
                  Smart Faculty & Student
                  <span className="text-transparent bg-gradient-to-r from-cyan-300 via-blue-300 to-indigo-300 bg-clip-text"> Feedback System</span>
                </h1>
                <p className="text-xl text-cyan-100 drop-shadow-md">
                  Empowering Smart Feedback & Academic Excellence
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Login Options */}
        <section className="py-16">
          <div className="container">
            <div className="text-center mb-12">
              <h2 className="text-3xl font-bold mb-4">Select Your Role</h2>
              <p className="text-muted-foreground">
                Choose your login portal to get started
              </p>
            </div>

            <div className="grid gap-8 md:grid-cols-3 max-w-5xl mx-auto">
              <div className="group relative overflow-hidden rounded-xl border border-ice bg-card/80 backdrop-blur-sm p-8 shadow-ice hover:shadow-xl hover:glow-ice transition-all duration-300 animate-scale-in">
                <div className="flex flex-col items-center space-y-4 text-center">
                  <div className="rounded-full bg-gradient-to-br from-blue-100 to-cyan-100 p-4 group-hover:from-blue-200 group-hover:to-cyan-200 transition-all">
                    <ShieldCheck className="h-12 w-12 text-blue-600" />
                  </div>
                  <h3 className="text-2xl font-bold">Admin</h3>
                  <p className="text-sm text-muted-foreground">
                    Manage system, view analytics, and generate reports
                  </p>
                  <Button
                    onClick={() => navigate('/admin/login')}
                    className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 text-white shadow-lg"
                    size="lg"
                  >
                    Login as Admin
                  </Button>
                </div>
              </div>

              <div className="group relative overflow-hidden rounded-xl border border-ice bg-card/80 backdrop-blur-sm p-8 shadow-ice hover:shadow-xl hover:glow-ice transition-all duration-300 animate-scale-in" style={{ animationDelay: '0.1s' }}>
                <div className="flex flex-col items-center space-y-4 text-center">
                  <div className="rounded-full bg-gradient-to-br from-cyan-100 to-indigo-100 p-4 group-hover:from-cyan-200 group-hover:to-indigo-200 transition-all">
                    <UserCircle className="h-12 w-12 text-cyan-600" />
                  </div>
                  <h3 className="text-2xl font-bold">Faculty</h3>
                  <p className="text-sm text-muted-foreground">
                    View feedback, track performance, and manage profile
                  </p>
                  <Button
                    onClick={() => navigate('/faculty/login')}
                    className="w-full bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-600 hover:to-blue-600 text-white shadow-lg"
                    size="lg"
                  >
                    Login as Faculty
                  </Button>
                </div>
              </div>

              <div className="group relative overflow-hidden rounded-xl border border-ice bg-card/80 backdrop-blur-sm p-8 shadow-ice hover:shadow-xl hover:glow-ice transition-all duration-300 animate-scale-in" style={{ animationDelay: '0.2s' }}>
                <div className="flex flex-col items-center space-y-4 text-center">
                  <div className="rounded-full bg-gradient-to-br from-indigo-100 to-purple-100 p-4 group-hover:from-indigo-200 group-hover:to-purple-200 transition-all">
                    <GraduationCap className="h-12 w-12 text-indigo-600" />
                  </div>
                  <h3 className="text-2xl font-bold">Student</h3>
                  <p className="text-sm text-muted-foreground">
                    Submit feedback, earn rewards, and track progress
                  </p>
                  <Button
                    onClick={() => navigate('/student/login')}
                    className="w-full bg-gradient-to-r from-indigo-500 to-purple-500 hover:from-indigo-600 hover:to-purple-600 text-white shadow-lg"
                    size="lg"
                  >
                    Login as Student
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
};

export default Home;
