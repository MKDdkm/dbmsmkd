import React, { useEffect, useState, useCallback } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { toast } from '@/hooks/use-toast';
import { 
  LogOut, MessageSquare, Star, TrendingUp, Users, Search, Filter, Download, Calendar, 
  BarChart3, PieChart, Eye, Reply, Bell, Settings, Target, Award, Clock, 
  FileText, Mail, Phone, MapPin, BookOpen, Zap, Heart, ThumbsUp, AlertTriangle,
  Send, Save, Edit, Trash2, Plus, Check, X, RefreshCw, Share2, PrinterIcon, User
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';

interface Student {
  id: string;
  usn: string;
  name: string;
  email: string;
  semester: number;
  branch: string;
}

interface Feedback {
  id: string;
  comment: string;
  ratings: {
    communication?: number;
    clarity?: number;
    knowledge?: number;
    punctuality?: number;
    behavior?: number;
  };
  sentiment: string;
  createdAt: string;
  student: Student;
  isRead?: boolean;
  response?: string;
  reply?: string;
  repliedAt?: string;
}

interface FacultyProfile {
  id: string;
  name: string;
  email: string;
  department: string;
  specialization?: string;
  experience?: string;
  qualifications?: string;
  phone?: string;
  office?: string;
}

const FacultyDashboard: React.FC = () => {
  const navigate = useNavigate();
  const [feedbacks, setFeedbacks] = useState<Feedback[]>([]);
  const [filteredFeedbacks, setFilteredFeedbacks] = useState<Feedback[]>([]);
  const [facultyInfo, setFacultyInfo] = useState<{
    id: string;
    name: string;
    email: string;
    branch?: string;
  } | null>(null);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [sentimentFilter, setSentimentFilter] = useState('all');
  const [dateFilter, setDateFilter] = useState('all');
  const [selectedFeedback, setSelectedFeedback] = useState<Feedback | null>(null);
  const [activeTab, setActiveTab] = useState('overview');
  
  // New advanced features state
  const [replyText, setReplyText] = useState('');
  const [showReplyDialog, setShowReplyDialog] = useState(false);
  const [currentReplyFeedback, setCurrentReplyFeedback] = useState<Feedback | null>(null);
  const [goals, setGoals] = useState<Array<{
    id: string | number;
    title: string;
    description?: string;
    target: number;
    current: number;
    deadline: string;
    status?: string;
  }>>([]);
  const [announcements, setAnnouncements] = useState<Array<{
    id: string;
    title: string;
    content: string;
    type: string;
    date: string;
  }>>([]);
  const [profileEdit, setProfileEdit] = useState(false);
  const [notificationSettings, setNotificationSettings] = useState({
    email: true,
    desktop: true,
    negative_feedback: true,
    daily_summary: false
  });
  const [darkMode, setDarkMode] = useState(false);
  const [autoRefresh, setAutoRefresh] = useState(false);
  const [totalStudents, setTotalStudents] = useState<number>(0);

  useEffect(() => {
    const userInfo = JSON.parse(localStorage.getItem('user') || '{}');
    if (!userInfo.id) {
      navigate('/faculty/login');
      return;
    }
    setFacultyInfo(userInfo);
    fetchFeedbacks(userInfo.id);
    fetchTotalStudents();
  }, [navigate]);

  const fetchTotalStudents = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/students/count');
      const data = await response.json();
      setTotalStudents(data.count || 0);
    } catch (error) {
      console.error('Error fetching total students:', error);
    }
  };

  const filterFeedbacks = useCallback(() => {
    let filtered = feedbacks;

    // Search filter
    if (searchTerm) {
      filtered = filtered.filter(feedback => 
        feedback.student.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        feedback.student.usn.toLowerCase().includes(searchTerm.toLowerCase()) ||
        feedback.comment.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Sentiment filter
    if (sentimentFilter !== 'all') {
      filtered = filtered.filter(feedback => feedback.sentiment === sentimentFilter);
    }

    // Date filter
    if (dateFilter !== 'all') {
      const now = new Date();
      const filterDate = new Date();
      
      switch (dateFilter) {
        case 'today':
          filterDate.setHours(0, 0, 0, 0);
          break;
        case 'week':
          filterDate.setDate(now.getDate() - 7);
          break;
        case 'month':
          filterDate.setMonth(now.getMonth() - 1);
          break;
      }
      
      filtered = filtered.filter(feedback => new Date(feedback.createdAt) >= filterDate);
    }

    setFilteredFeedbacks(filtered);
  }, [feedbacks, searchTerm, sentimentFilter, dateFilter]);

  useEffect(() => {
    filterFeedbacks();
  }, [filterFeedbacks]);

  const fetchFeedbacks = async (facultyId: string) => {
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/api/faculty/${facultyId}/feedback`);
      if (response.ok) {
        const data = await response.json();
        setFeedbacks(data);
        setFilteredFeedbacks(data);
      }
    } catch (error) {
      console.error('Error fetching feedbacks:', error);
    } finally {
      setLoading(false);
    }
  };

  const exportToCSV = () => {
    const csvContent = [
      ['Student Name', 'USN', 'Comment', 'Sentiment', 'Date', 'Ratings'],
      ...filteredFeedbacks.map(feedback => [
        feedback.student.name,
        feedback.student.usn,
        feedback.comment.replace(/,/g, ';'), // Replace commas to avoid CSV issues
        feedback.sentiment,
        new Date(feedback.createdAt).toLocaleDateString(),
        JSON.stringify(feedback.ratings)
      ])
    ].map(row => row.join(',')).join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `feedback-report-${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const handleReplyToFeedback = async (feedback: Feedback) => {
    setCurrentReplyFeedback(feedback);
    setReplyText('');
    setShowReplyDialog(true);
  };

  const submitReply = async () => {
    if (!currentReplyFeedback || !replyText.trim()) return;

    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/api/feedback/${currentReplyFeedback.id}/reply`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ reply: replyText }),
      });

      if (response.ok) {
        const data = await response.json();
        // Update local feedbacks with reply
        setFeedbacks(prev => prev.map(f => 
          f.id === currentReplyFeedback.id 
            ? { ...f, reply: replyText, repliedAt: new Date().toISOString() } 
            : f
        ));
        
        toast({
          title: 'Reply Sent!',
          description: `Your response has been sent to ${currentReplyFeedback.student.name}`,
        });
        setShowReplyDialog(false);
        setReplyText('');
        setCurrentReplyFeedback(null);
      } else {
        throw new Error('Failed to send reply');
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to send reply. Please try again.',
        variant: 'destructive',
      });
    }
  };

  const markFeedbackAsRead = (feedbackId: string) => {
    setFeedbacks(prev => prev.map(f => 
      f.id === feedbackId ? { ...f, isRead: true } : f
    ));
  };

  const createGoal = () => {
    const newGoal = {
      id: Date.now(),
      title: 'Improve Communication Skills',
      target: 4.5,
      current: stats.averageRating,
      deadline: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      status: 'active'
    };
    setGoals(prev => [...prev, newGoal]);
    toast({
      title: 'Goal Created!',
      description: 'New performance goal has been set.',
    });
  };

  const shareReport = () => {
    if (navigator.share) {
      navigator.share({
        title: 'Faculty Feedback Report',
        text: `Check out my latest feedback report with ${stats.totalFeedbacks} feedbacks and ${stats.averageRating.toFixed(1)} average rating!`,
        url: window.location.href
      });
    } else {
      navigator.clipboard.writeText(window.location.href);
      toast({
        title: 'Link Copied!',
        description: 'Dashboard link copied to clipboard.',
      });
    }
  };

  const printReport = () => {
    window.print();
  };

  const refreshData = () => {
    if (facultyInfo?.id) {
      fetchFeedbacks(facultyInfo.id);
      toast({
        title: 'Refreshed!',
        description: 'Dashboard data has been updated.',
      });
    }
  };

  // Auto-refresh functionality
  useEffect(() => {
    if (autoRefresh) {
      const interval = setInterval(() => {
        if (facultyInfo?.id) {
          fetchFeedbacks(facultyInfo.id);
        }
      }, 30000); // Refresh every 30 seconds

      return () => clearInterval(interval);
    }
  }, [autoRefresh, facultyInfo]);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/');
  };

  const getSentimentColor = (sentiment: string) => {
    switch (sentiment) {
      case 'positive': return 'bg-green-100 text-green-800';
      case 'negative': return 'bg-red-100 text-red-800';
      case 'neutral': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const calculateStats = () => {
    const totalFeedbacks = filteredFeedbacks.length;
    const uniqueStudents = new Set(filteredFeedbacks.map(f => f.student.id)).size;
    const averageRating = filteredFeedbacks.length > 0 
      ? filteredFeedbacks.reduce((sum, feedback) => {
          // Calculate average from all rating components
          const ratings = feedback.ratings;
          const ratingValues = [
            ratings.communication || 0,
            ratings.clarity || 0,
            ratings.knowledge || 0,
            ratings.punctuality || 0,
            ratings.behavior || 0
          ].filter(v => v > 0);
          
          const avgRating = ratingValues.length > 0 
            ? ratingValues.reduce((a, b) => a + b, 0) / ratingValues.length
            : 4; // default rating
          
          return sum + avgRating;
        }, 0) / filteredFeedbacks.length 
      : 0;
    
    const sentimentCounts = filteredFeedbacks.reduce((acc, f) => {
      acc[f.sentiment] = (acc[f.sentiment] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const recentFeedbacks = filteredFeedbacks.filter(f => 
      new Date(f.createdAt) >= new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
    ).length;

    return { totalFeedbacks, uniqueStudents, averageRating, sentimentCounts, recentFeedbacks };
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
          <p className="mt-4 text-gray-600">Loading your feedback dashboard...</p>
        </div>
      </div>
    );
  }

  const stats = calculateStats();

  return (
    <div className={`min-h-screen ${darkMode ? 'bg-gray-900 text-white' : 'bg-gray-50'}`}>
      {/* Enhanced Header */}
      <div className={`${darkMode ? 'bg-gray-800' : 'bg-white'} shadow-sm border-b`}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-4">
              <div>
                <h1 className="text-2xl font-bold">Faculty Dashboard</h1>
                <p className="text-sm text-muted-foreground">Welcome back, {facultyInfo?.name}</p>
              </div>
              {stats.sentimentCounts.negative > 0 && (
                <Badge variant="destructive" className="animate-pulse">
                  <AlertTriangle className="h-3 w-3 mr-1" />
                  {stats.sentimentCounts.negative} Negative
                </Badge>
              )}
            </div>
            
            <div className="flex items-center space-x-2">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setAutoRefresh(!autoRefresh)}
                className={autoRefresh ? 'bg-green-100' : ''}
              >
                <RefreshCw className={`h-4 w-4 ${autoRefresh ? 'animate-spin' : ''}`} />
              </Button>
              
              <Button variant="ghost" size="sm" onClick={refreshData}>
                <Zap className="h-4 w-4" />
              </Button>
              
              <Button variant="ghost" size="sm" onClick={shareReport}>
                <Share2 className="h-4 w-4" />
              </Button>
              
              <Button variant="ghost" size="sm" onClick={printReport}>
                <PrinterIcon className="h-4 w-4" />
              </Button>
              
              <Dialog>
                <DialogTrigger asChild>
                  <Button variant="ghost" size="sm">
                    <Settings className="h-4 w-4" />
                  </Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Settings</DialogTitle>
                  </DialogHeader>
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <span>Dark Mode</span>
                      <Button
                        variant={darkMode ? "default" : "outline"}
                        size="sm"
                        onClick={() => setDarkMode(!darkMode)}
                      >
                        {darkMode ? 'On' : 'Off'}
                      </Button>
                    </div>
                    <div className="flex items-center justify-between">
                      <span>Auto Refresh (30s)</span>
                      <Button
                        variant={autoRefresh ? "default" : "outline"}
                        size="sm"
                        onClick={() => setAutoRefresh(!autoRefresh)}
                      >
                        {autoRefresh ? 'On' : 'Off'}
                      </Button>
                    </div>
                    <div className="space-y-2">
                      <span>Notifications</span>
                      <div className="space-y-1 text-sm">
                        <label className="flex items-center">
                          <input
                            type="checkbox"
                            checked={notificationSettings.email}
                            onChange={(e) => setNotificationSettings(prev => ({...prev, email: e.target.checked}))}
                            className="mr-2"
                          />
                          Email notifications
                        </label>
                        <label className="flex items-center">
                          <input
                            type="checkbox"
                            checked={notificationSettings.negative_feedback}
                            onChange={(e) => setNotificationSettings(prev => ({...prev, negative_feedback: e.target.checked}))}
                            className="mr-2"
                          />
                          Alert on negative feedback
                        </label>
                      </div>
                    </div>
                  </div>
                </DialogContent>
              </Dialog>
              
              <Button onClick={exportToCSV} variant="outline" size="sm">
                <Download className="h-4 w-4 mr-2" />
                Export
              </Button>
              
              <Button onClick={handleLogout} variant="outline" size="sm">
                <LogOut className="h-4 w-4 mr-2" />
                Logout
              </Button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-6">
            <TabsTrigger value="overview">Overview</TabsTrigger>
            <TabsTrigger value="feedbacks">
              Feedbacks
              {stats.sentimentCounts.negative > 0 && (
                <Badge variant="destructive" className="ml-1 text-xs">
                  {stats.sentimentCounts.negative}
                </Badge>
              )}
            </TabsTrigger>
            <TabsTrigger value="analytics">Analytics</TabsTrigger>
            <TabsTrigger value="goals">Goals</TabsTrigger>
            <TabsTrigger value="profile">Profile</TabsTrigger>
            <TabsTrigger value="reports">Reports</TabsTrigger>
          </TabsList>

          <TabsContent value="overview" className="space-y-6 mt-6">
            {/* Stats Overview */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Total Feedbacks</CardTitle>
                  <MessageSquare className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.totalFeedbacks}</div>
                  <p className="text-xs text-muted-foreground">
                    From {stats.uniqueStudents} students
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Average Rating</CardTitle>
                  <Star className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.averageRating.toFixed(1)}</div>
                  <p className="text-xs text-muted-foreground">
                    Out of 5.0
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Recent Feedback</CardTitle>
                  <Calendar className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats.recentFeedbacks}</div>
                  <p className="text-xs text-muted-foreground">
                    Last 7 days
                  </p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">Positive Rate</CardTitle>
                  <TrendingUp className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">
                    {stats.totalFeedbacks > 0 ? Math.round((stats.sentimentCounts.positive || 0) / stats.totalFeedbacks * 100) : 0}%
                  </div>
                  <p className="text-xs text-muted-foreground">
                    Positive sentiment
                  </p>
                </CardContent>
              </Card>
            </div>

            {/* Quick Analytics */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <PieChart className="h-5 w-5" />
                    Sentiment Distribution
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center">
                      <span className="text-sm">Positive</span>
                      <div className="flex items-center gap-2">
                        <div className="w-20 bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-green-500 h-2 rounded-full" 
                            style={{width: `${stats.totalFeedbacks > 0 ? (stats.sentimentCounts.positive || 0) / stats.totalFeedbacks * 100 : 0}%`}}
                          ></div>
                        </div>
                        <span className="text-sm">{stats.sentimentCounts.positive || 0}</span>
                      </div>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm">Neutral</span>
                      <div className="flex items-center gap-2">
                        <div className="w-20 bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-yellow-500 h-2 rounded-full" 
                            style={{width: `${stats.totalFeedbacks > 0 ? (stats.sentimentCounts.neutral || 0) / stats.totalFeedbacks * 100 : 0}%`}}
                          ></div>
                        </div>
                        <span className="text-sm">{stats.sentimentCounts.neutral || 0}</span>
                      </div>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-sm">Negative</span>
                      <div className="flex items-center gap-2">
                        <div className="w-20 bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-red-500 h-2 rounded-full" 
                            style={{width: `${stats.totalFeedbacks > 0 ? (stats.sentimentCounts.negative || 0) / stats.totalFeedbacks * 100 : 0}%`}}
                          ></div>
                        </div>
                        <span className="text-sm">{stats.sentimentCounts.negative || 0}</span>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Users className="h-5 w-5" />
                    Student Engagement
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex justify-between">
                      <span className="text-sm">Total Students</span>
                      <span className="font-medium">{totalStudents}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm">Avg Feedback/Student</span>
                      <span className="font-medium">
                        {totalStudents > 0 ? (stats.totalFeedbacks / totalStudents).toFixed(1) : 0}
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-sm">Recent Activity</span>
                      <span className="font-medium">{stats.recentFeedbacks} this week</span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          <TabsContent value="feedbacks" className="space-y-6 mt-6">
            {/* Filters */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Filter className="h-5 w-5" />
                  Filter & Search Feedbacks
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div className="relative">
                    <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="Search students or comments..."
                      className="pl-10"
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                    />
                  </div>
                  
                  <Select value={sentimentFilter} onValueChange={setSentimentFilter}>
                    <SelectTrigger>
                      <SelectValue placeholder="Filter by sentiment" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Sentiments</SelectItem>
                      <SelectItem value="positive">Positive</SelectItem>
                      <SelectItem value="neutral">Neutral</SelectItem>
                      <SelectItem value="negative">Negative</SelectItem>
                    </SelectContent>
                  </Select>

                  <Select value={dateFilter} onValueChange={setDateFilter}>
                    <SelectTrigger>
                      <SelectValue placeholder="Filter by date" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Time</SelectItem>
                      <SelectItem value="today">Today</SelectItem>
                      <SelectItem value="week">This Week</SelectItem>
                      <SelectItem value="month">This Month</SelectItem>
                    </SelectContent>
                  </Select>

                  <Button 
                    variant="outline" 
                    onClick={() => {
                      setSearchTerm('');
                      setSentimentFilter('all');
                      setDateFilter('all');
                    }}
                  >
                    Clear Filters
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Feedback List */}
            <Card>
              <CardHeader>
                <CardTitle>
                  Student Feedback ({filteredFeedbacks.length} of {feedbacks.length})
                </CardTitle>
              </CardHeader>
              <CardContent>
                {filteredFeedbacks.length === 0 ? (
                  <div className="text-center py-12">
                    <MessageSquare className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                    <h3 className="text-lg font-medium text-gray-900 mb-2">No feedback found</h3>
                    <p className="text-gray-600">
                      {feedbacks.length === 0 
                        ? "Students haven't submitted any feedback for you yet." 
                        : "Try adjusting your filters to see more results."
                      }
                    </p>
                  </div>
                ) : (
                  <div className="space-y-4">
                    {filteredFeedbacks.map((feedback) => (
                      <div key={feedback.id} className="border rounded-lg p-6 hover:shadow-md transition-shadow">
                        <div className="flex justify-between items-start mb-4">
                          <div>
                            <h4 className="font-semibold text-lg">{feedback.student.name}</h4>
                            <p className="text-sm text-gray-600">
                              {feedback.student.usn} • {feedback.student.branch} • Semester {feedback.student.semester}
                            </p>
                            <p className="text-xs text-gray-500">{feedback.student.email}</p>
                          </div>
                          <div className="text-right">
                            <Badge className={getSentimentColor(feedback.sentiment)}>
                              {feedback.sentiment}
                            </Badge>
                            <p className="text-xs text-gray-500 mt-1">
                              {new Date(feedback.createdAt).toLocaleDateString()}
                            </p>
                          </div>
                        </div>
                        
                        <div className="mb-4">
                          <h5 className="font-medium mb-2">Feedback Comment:</h5>
                          <p className="text-gray-700 bg-gray-50 p-3 rounded border-l-4 border-blue-500">
                            "{feedback.comment}"
                          </p>
                        </div>

                        {feedback.ratings && typeof feedback.ratings === 'object' && (
                          <div className="mb-4">
                            <h5 className="font-medium mb-2">Ratings:</h5>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                              {Object.entries(feedback.ratings).map(([key, value]) => (
                                <div key={key} className="flex justify-between">
                                  <span className="capitalize">{key}:</span>
                                  <div className="flex items-center">
                                    <span className="font-medium">{String(value)}/5</span>
                                    <Star className="h-3 w-3 text-yellow-400 ml-1" />
                                  </div>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}

                        {feedback.reply && (
                          <div className="mb-4">
                            <h5 className="font-medium mb-2 text-green-600">Your Reply:</h5>
                            <p className="text-gray-700 bg-green-50 p-3 rounded border-l-4 border-green-500">
                              {feedback.reply}
                            </p>
                            <p className="text-xs text-gray-500 mt-1">
                              Replied on {new Date(feedback.repliedAt!).toLocaleString()}
                            </p>
                          </div>
                        )}

                        <div className="flex gap-2">
                          <Button 
                            size="sm" 
                            variant="outline"
                            onClick={() => {
                              setSelectedFeedback(feedback);
                              markFeedbackAsRead(feedback.id);
                            }}
                          >
                            <Eye className="h-4 w-4 mr-1" />
                            View Details
                          </Button>
                          <Button 
                            size="sm" 
                            variant="outline"
                            onClick={() => handleReplyToFeedback(feedback)}
                          >
                            <Reply className="h-4 w-4 mr-1" />
                            Reply
                          </Button>
                          <Button 
                            size="sm" 
                            variant={feedback.sentiment === 'negative' ? 'destructive' : 'ghost'}
                          >
                            {feedback.sentiment === 'positive' && <Heart className="h-4 w-4" />}
                            {feedback.sentiment === 'neutral' && <ThumbsUp className="h-4 w-4" />}
                            {feedback.sentiment === 'negative' && <AlertTriangle className="h-4 w-4" />}
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="analytics" className="space-y-6 mt-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <BarChart3 className="h-5 w-5" />
                  Advanced Analytics
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  {/* Ratings Over Time Chart */}
                  <Card>
                    <CardHeader>
                      <CardTitle className="text-base">Average Ratings Trend</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="h-64 flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-50 rounded-lg">
                        {filteredFeedbacks.length > 0 ? (
                          <div className="w-full p-4">
                            <div className="space-y-4">
                              {['communication', 'clarity', 'knowledge', 'punctuality', 'behavior'].map((metric) => {
                                const avg = filteredFeedbacks.reduce((sum, f) => {
                                  const rating = f.ratings[metric as keyof typeof f.ratings] || 0;
                                  return sum + rating;
                                }, 0) / filteredFeedbacks.length;
                                const percentage = (avg / 5) * 100;
                                
                                return (
                                  <div key={metric}>
                                    <div className="flex justify-between text-sm mb-1">
                                      <span className="capitalize font-medium">{metric}</span>
                                      <span className="text-gray-600">{avg.toFixed(1)}/5</span>
                                    </div>
                                    <div className="w-full bg-gray-200 rounded-full h-3">
                                      <div 
                                        className="bg-gradient-to-r from-blue-500 to-indigo-600 h-3 rounded-full transition-all duration-500"
                                        style={{ width: `${percentage}%` }}
                                      />
                                    </div>
                                  </div>
                                );
                              })}
                            </div>
                          </div>
                        ) : (
                          <p className="text-gray-500">No feedback data available</p>
                        )}
                      </div>
                    </CardContent>
                  </Card>

                  {/* Sentiment Distribution */}
                  <div className="grid md:grid-cols-2 gap-6">
                    <Card>
                      <CardHeader>
                        <CardTitle className="text-base">Feedback Sentiment</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <div className="space-y-3">
                          {['positive', 'neutral', 'negative'].map((sentiment) => {
                            const count = filteredFeedbacks.filter(f => f.sentiment === sentiment).length;
                            const percentage = filteredFeedbacks.length > 0 ? (count / filteredFeedbacks.length) * 100 : 0;
                            const color = sentiment === 'positive' ? 'bg-green-500' : sentiment === 'neutral' ? 'bg-yellow-500' : 'bg-red-500';
                            
                            return (
                              <div key={sentiment}>
                                <div className="flex justify-between text-sm mb-1">
                                  <span className="capitalize font-medium">{sentiment}</span>
                                  <span className="text-gray-600">{count} ({percentage.toFixed(0)}%)</span>
                                </div>
                                <div className="w-full bg-gray-200 rounded-full h-2">
                                  <div 
                                    className={`${color} h-2 rounded-full transition-all duration-500`}
                                    style={{ width: `${percentage}%` }}
                                  />
                                </div>
                              </div>
                            );
                          })}
                        </div>
                      </CardContent>
                    </Card>

                    <Card>
                      <CardHeader>
                        <CardTitle className="text-base">Key Metrics</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <div className="space-y-4">
                          <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                            <div className="flex items-center gap-2">
                              <MessageSquare className="h-5 w-5 text-blue-600" />
                              <span className="font-medium">Total Feedback</span>
                            </div>
                            <span className="text-2xl font-bold text-blue-600">{filteredFeedbacks.length}</span>
                          </div>
                          <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
                            <div className="flex items-center gap-2">
                              <Star className="h-5 w-5 text-green-600" />
                              <span className="font-medium">Avg Rating</span>
                            </div>
                            <span className="text-2xl font-bold text-green-600">
                              {filteredFeedbacks.length > 0
                                ? (filteredFeedbacks.reduce((sum, f) => {
                                    const ratings = Object.values(f.ratings);
                                    return sum + ratings.reduce((a, b) => a + (b || 0), 0) / ratings.length;
                                  }, 0) / filteredFeedbacks.length).toFixed(1)
                                : '0.0'}
                            </span>
                          </div>
                          <div className="flex items-center justify-between p-3 bg-purple-50 rounded-lg">
                            <div className="flex items-center gap-2">
                              <Reply className="h-5 w-5 text-purple-600" />
                              <span className="font-medium">Replied</span>
                            </div>
                            <span className="text-2xl font-bold text-purple-600">
                              {filteredFeedbacks.filter(f => f.reply).length}
                            </span>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="goals" className="space-y-6 mt-6">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <CardTitle className="flex items-center gap-2">
                    <Target className="h-5 w-5" />
                    Performance Goals
                  </CardTitle>
                  <Button onClick={createGoal}>
                    <Plus className="h-4 w-4 mr-2" />
                    Set New Goal
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="grid gap-4">
                  {goals.length === 0 ? (
                    <div className="text-center py-12">
                      <Target className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                      <h3 className="text-lg font-medium mb-2">No Goals Set</h3>
                      <p className="text-gray-600 mb-4">Set performance goals to track your improvement</p>
                      <Button onClick={createGoal}>
                        <Plus className="h-4 w-4 mr-2" />
                        Create First Goal
                      </Button>
                    </div>
                  ) : (
                    goals.map((goal) => (
                      <Card key={goal.id}>
                        <CardContent className="p-4">
                          <div className="flex justify-between items-start mb-2">
                            <h4 className="font-medium">{goal.title}</h4>
                            <Badge variant={goal.current >= goal.target ? 'default' : 'secondary'}>
                              {goal.current >= goal.target ? 'Achieved' : 'In Progress'}
                            </Badge>
                          </div>
                          <div className="space-y-2">
                            <div className="flex justify-between text-sm">
                              <span>Current: {goal.current.toFixed(1)}</span>
                              <span>Target: {goal.target}</span>
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-2">
                              <div 
                                className="bg-blue-600 h-2 rounded-full" 
                                style={{width: `${Math.min((goal.current / goal.target) * 100, 100)}%`}}
                              ></div>
                            </div>
                            <p className="text-xs text-gray-500">Deadline: {goal.deadline}</p>
                          </div>
                        </CardContent>
                      </Card>
                    ))
                  )}
                </div>
              </CardContent>
            </Card>

            {/* Achievement Badges */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Award className="h-5 w-5" />
                  Achievements
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div className={`p-4 rounded-lg text-center ${stats.totalFeedbacks >= 10 ? 'bg-yellow-100' : 'bg-gray-100'}`}>
                    <Award className={`h-8 w-8 mx-auto mb-2 ${stats.totalFeedbacks >= 10 ? 'text-yellow-600' : 'text-gray-400'}`} />
                    <p className="font-medium">Feedback Collector</p>
                    <p className="text-xs">10+ Feedbacks</p>
                  </div>
                  
                  <div className={`p-4 rounded-lg text-center ${stats.averageRating >= 4.5 ? 'bg-green-100' : 'bg-gray-100'}`}>
                    <Star className={`h-8 w-8 mx-auto mb-2 ${stats.averageRating >= 4.5 ? 'text-green-600' : 'text-gray-400'}`} />
                    <p className="font-medium">Excellence</p>
                    <p className="text-xs">4.5+ Rating</p>
                  </div>
                  
                  <div className={`p-4 rounded-lg text-center ${(stats.sentimentCounts.positive || 0) / stats.totalFeedbacks >= 0.8 ? 'bg-blue-100' : 'bg-gray-100'}`}>
                    <Heart className={`h-8 w-8 mx-auto mb-2 ${(stats.sentimentCounts.positive || 0) / stats.totalFeedbacks >= 0.8 ? 'text-blue-600' : 'text-gray-400'}`} />
                    <p className="font-medium">Beloved Teacher</p>
                    <p className="text-xs">80% Positive</p>
                  </div>
                  
                  <div className={`p-4 rounded-lg text-center ${stats.uniqueStudents >= 20 ? 'bg-purple-100' : 'bg-gray-100'}`}>
                    <Users className={`h-8 w-8 mx-auto mb-2 ${stats.uniqueStudents >= 20 ? 'text-purple-600' : 'text-gray-400'}`} />
                    <p className="font-medium">Popular Educator</p>
                    <p className="text-xs">20+ Students</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="profile" className="space-y-6 mt-6">
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <CardTitle className="flex items-center gap-2">
                    <User className="h-5 w-5" />
                    Faculty Profile
                  </CardTitle>
                  <Button variant="outline" onClick={() => setProfileEdit(!profileEdit)}>
                    <Edit className="h-4 w-4 mr-2" />
                    {profileEdit ? 'Save' : 'Edit'}
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Full Name</label>
                      {profileEdit ? (
                        <Input value={facultyInfo?.name || ''} />
                      ) : (
                        <p className="text-gray-900">{facultyInfo?.name || 'Not specified'}</p>
                      )}
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Email</label>
                      <div className="flex items-center gap-2">
                        <Mail className="h-4 w-4 text-gray-400" />
                        <p className="text-gray-900">{facultyInfo?.email || 'Not specified'}</p>
                      </div>
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Department</label>
                      {profileEdit ? (
                        <Input value={facultyInfo?.branch || 'Computer Science'} />
                      ) : (
                        <p className="text-gray-900">{facultyInfo?.branch || 'Computer Science'}</p>
                      )}
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Specialization</label>
                      {profileEdit ? (
                        <Input placeholder="e.g. Data Science, Web Development" />
                      ) : (
                        <p className="text-gray-900">Data Science & Machine Learning</p>
                      )}
                    </div>
                  </div>
                  
                  <div className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium mb-1">Experience</label>
                      {profileEdit ? (
                        <Input placeholder="Years of experience" />
                      ) : (
                        <p className="text-gray-900">5+ Years</p>
                      )}
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Phone</label>
                      {profileEdit ? (
                        <Input placeholder="Contact number" />
                      ) : (
                        <div className="flex items-center gap-2">
                          <Phone className="h-4 w-4 text-gray-400" />
                          <p className="text-gray-900">+91 98765 43210</p>
                        </div>
                      )}
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Office</label>
                      {profileEdit ? (
                        <Input placeholder="Office location" />
                      ) : (
                        <div className="flex items-center gap-2">
                          <MapPin className="h-4 w-4 text-gray-400" />
                          <p className="text-gray-900">Room 201, CS Department</p>
                        </div>
                      )}
                    </div>
                    
                    <div>
                      <label className="block text-sm font-medium mb-1">Qualifications</label>
                      {profileEdit ? (
                        <Textarea placeholder="Educational qualifications" />
                      ) : (
                        <div className="flex items-center gap-2">
                          <BookOpen className="h-4 w-4 text-gray-400" />
                          <p className="text-gray-900">M.Tech in Computer Science, B.Tech in IT</p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Quick Stats Card */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <BarChart3 className="h-5 w-5" />
                  Teaching Statistics
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
                  <div>
                    <p className="text-2xl font-bold text-blue-600">{stats.totalFeedbacks}</p>
                    <p className="text-sm text-gray-600">Total Feedbacks</p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-green-600">{stats.averageRating.toFixed(1)}</p>
                    <p className="text-sm text-gray-600">Average Rating</p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-purple-600">{totalStudents}</p>
                    <p className="text-sm text-gray-600">Students Taught</p>
                  </div>
                  <div>
                    <p className="text-2xl font-bold text-orange-600">
                      {stats.totalFeedbacks > 0 ? Math.round((stats.sentimentCounts.positive || 0) / stats.totalFeedbacks * 100) : 0}%
                    </p>
                    <p className="text-sm text-gray-600">Satisfaction Rate</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="reports" className="space-y-6 mt-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Download className="h-5 w-5" />
                  Generate Reports
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <Card>
                      <CardContent className="p-4">
                        <h4 className="font-medium mb-2">Feedback Summary Report</h4>
                        <p className="text-sm text-gray-600 mb-4">
                          Complete overview of all feedback with statistics
                        </p>
                        <Button onClick={exportToCSV} className="w-full">
                          <Download className="h-4 w-4 mr-2" />
                          Download CSV
                        </Button>
                      </CardContent>
                    </Card>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        {/* Reply Dialog */}
        <Dialog open={showReplyDialog} onOpenChange={setShowReplyDialog}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Reply to {currentReplyFeedback?.student.name}</DialogTitle>
            </DialogHeader>
            <div className="space-y-4">
              <div className="p-3 bg-gray-50 rounded">
                <p className="text-sm font-medium">Original Feedback:</p>
                <p className="text-sm text-gray-600">"{currentReplyFeedback?.comment}"</p>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-2">Your Response:</label>
                <Textarea
                  placeholder="Type your response to the student..."
                  value={replyText}
                  onChange={(e) => setReplyText(e.target.value)}
                  rows={4}
                />
              </div>
              
              <div className="flex justify-end gap-2">
                <Button variant="outline" onClick={() => setShowReplyDialog(false)}>
                  Cancel
                </Button>
                <Button onClick={submitReply} disabled={!replyText.trim()}>
                  <Send className="h-4 w-4 mr-2" />
                  Send Reply
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
};

export default FacultyDashboard;