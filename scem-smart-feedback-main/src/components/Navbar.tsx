import { Moon, Sun, Menu, Info } from 'lucide-react';
import { useTheme } from '@/contexts/ThemeContext';
import { Button } from '@/components/ui/button';
import Logo from '@/components/Logo';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from '@/components/ui/sheet';

export const Navbar = () => {
  const { theme, toggleTheme } = useTheme();

  return (
    <nav className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 items-center justify-between">
        <div className="flex items-center gap-4">
          <Logo size="lg" showText={false} />
          <div className="hidden md:block">
            <h1 className="text-lg font-semibold text-foreground">
              Sahyadri College of Engineering & Management
            </h1>
            <p className="text-xs text-muted-foreground">SCEM</p>
          </div>
          <div className="md:hidden">
            <h1 className="text-sm font-semibold">SCEM</h1>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="icon"
            onClick={toggleTheme}
            className="h-9 w-9"
          >
            {theme === 'light' ? (
              <Moon className="h-4 w-4" />
            ) : (
              <Sun className="h-4 w-4" />
            )}
          </Button>

          <Sheet>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" className="h-9 w-9">
                <Info className="h-4 w-4" />
              </Button>
            </SheetTrigger>
            <SheetContent>
              <SheetHeader>
                <SheetTitle>About SCEM</SheetTitle>
                <SheetDescription>
                  Smart Faculty & Student Feedback System
                </SheetDescription>
              </SheetHeader>
              <div className="mt-6 space-y-4">
                <p className="text-sm text-muted-foreground">
                  Sahyadri College of Engineering & Management is committed to
                  providing quality education and fostering academic excellence.
                </p>
                <p className="text-sm text-muted-foreground">
                  Our Smart Feedback System empowers students and faculty to
                  collaborate for continuous improvement in teaching and learning.
                </p>
                <div className="mt-6 rounded-lg bg-primary/10 p-4">
                  <h3 className="font-semibold text-sm mb-2">Contact</h3>
                  <p className="text-xs text-muted-foreground">
                    Email: info@scem.ac.in<br />
                    Phone: +91 123 456 7890
                  </p>
                </div>
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </nav>
  );
};
