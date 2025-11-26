import React from 'react';
import { cn } from '@/lib/utils';

interface LogoProps {
  className?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  showText?: boolean;
  text?: string;
}

const Logo: React.FC<LogoProps> = ({ 
  className, 
  size = 'md', 
  showText = true,
  text = 'SCEM Smart Feedback'
}) => {
  const sizeClasses = {
    sm: 'h-8 w-8',
    md: 'h-12 w-12',
    lg: 'h-16 w-16',
    xl: 'h-20 w-20'
  };

  const textSizeClasses = {
    sm: 'text-lg',
    md: 'text-xl',
    lg: 'text-2xl',
    xl: 'text-3xl'
  };

  return (
    <div className={cn('flex items-center gap-3', className)}>
      <img
        src="/logo.png"
        alt="SCEM Smart Feedback Logo"
        className={cn(
          'object-contain rounded-lg shadow-sm',
          sizeClasses[size]
        )}
      />
      {showText && (
        <span className={cn(
          'font-bold text-primary tracking-tight',
          textSizeClasses[size]
        )}>
          {text}
        </span>
      )}
    </div>
  );
};

export default Logo;