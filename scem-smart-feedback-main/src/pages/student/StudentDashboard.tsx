import { useEffect, useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Navbar } from '@/components/Navbar';
import { Footer } from '@/components/Footer';
import { DashboardCard } from '@/components/DashboardCard';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import {
  Award,
  MessageSquare,
  CheckCircle2,
  LogOut,
  Bell,
  Star,
  TrendingUp,
  Calendar,
  Trophy,
} from 'lucide-react';
import ChatBot from '@/components/ChatBot';
// import { mockFaculties, mockFeedbacks, mockStudents } from '@/lib/mockData';
import { useToast } from '@/hooks/use-toast';
import { Slider } from '@/components/ui/slider';

const StudentDashboard = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [activeTab, setActiveTab] = useState('dashboard');
  const [currentStudent, setCurrentStudent] = useState<{
    id: string;
    name: string;
    email: string;
    usn: string;
    semester?: number;
    branch?: string;
  } | null>(null);
  const [faculties, setFaculties] = useState<{ id: string; name: string; department: string; subjects?: string[] }[]>([]);
  const [feedbackHistory, setFeedbackHistory] = useState<any[]>([]);
  const [selectedSemester, setSelectedSemester] = useState('');
  const [selectedSubject, setSelectedSubject] = useState('');
  const [selectedFaculty, setSelectedFaculty] = useState('');
  const [filteredSubjects, setFilteredSubjects] = useState<{ id: string; name: string; code: string }[]>([]);
  const [filteredFaculties, setFilteredFaculties] = useState<{ id: string; name: string; department: string; subjects?: string[] }[]>([]);
  const [ratings, setRatings] = useState({
    communication: 5,
    clarity: 5,
    knowledge: 5,
    punctuality: 5,
    behavior: 5,
  });
  const [comment, setComment] = useState('');

  // Load authenticated student and faculty list from backend
  useEffect(() => {
    try {
      const userRaw = localStorage.getItem('user');
      
      if (userRaw && userRaw !== 'undefined' && userRaw !== 'null') {
        const user = JSON.parse(userRaw);
        if (user && user.id) {
          setCurrentStudent(user);
        } else {
          localStorage.removeItem('user');
          localStorage.removeItem('token');
          navigate('/student/login');
          return;
        }
      } else {
        localStorage.removeItem('user');
        localStorage.removeItem('token');
        navigate('/student/login');
        return;
      }
    } catch (error) {
      console.error('Error parsing user from localStorage:', error);
      localStorage.removeItem('user');
      localStorage.removeItem('token');
      navigate('/student/login');
      return;
    }

    const loadFaculties = async () => {
      try {
        const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000';
        
        const res = await fetch(`${apiUrl}/api/faculty`);
        
        if (!res.ok) {
          throw new Error(`HTTP ${res.status}: ${res.statusText}`);
        }
        
        const list = await res.json();
        
        const uiList = (Array.isArray(list) ? list : []).map((f: {
          id: string;
          name: string;
          branch?: string;
        }) => ({
          id: f.id,
          name: f.name,
          department: f.branch ?? 'Department',
          subjects: [] // Default empty subjects for now
        }));
        
        setFaculties(uiList);
      } catch (e: unknown) {
        const error = e as Error;
        console.error('Failed to load faculties:', error);
        toast({ title: 'Failed to load faculties', description: error.message || 'Please try again later', variant: 'destructive' });
      }
    };

    const loadFeedbackHistory = async () => {
      if (!userRaw) return;
      try {
        const user = JSON.parse(userRaw);
        const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000';
        const res = await fetch(`${apiUrl}/api/students/${user.id}/feedback`);
        if (res.ok) {
          const data = await res.json();
          setFeedbackHistory(data);
        }
      } catch (error) {
        console.error('Failed to load feedback history:', error);
      }
    };

    loadFaculties();
    loadFeedbackHistory();
  }, [navigate, toast]);

  // Semester-Subject mapping for CSE curriculum
  const semesterSubjects = useMemo(() => ({
    '1': [
      { id: 'math1', name: 'Engineering Mathematics I', code: 'MA101' },
      { id: 'physics', name: 'Engineering Physics', code: 'PH101' },
      { id: 'chem', name: 'Engineering Chemistry', code: 'CH101' },
      { id: 'prog1', name: 'Programming in C', code: 'CS101' }
    ],
    '2': [
      { id: 'math2', name: 'Engineering Mathematics II', code: 'MA102' },
      { id: 'datastr', name: 'Data Structures', code: 'CS201' },
      { id: 'electronics', name: 'Digital Electronics', code: 'EC201' },
      { id: 'prog2', name: 'Object Oriented Programming', code: 'CS202' }
    ],
    '3': [
      { id: 'dsa', name: 'Algorithms & Design Analysis', code: 'CS301' },
      { id: 'dbms', name: 'Database Management Systems', code: 'CS302' },
      { id: 'os', name: 'Operating Systems', code: 'CS303' },
      { id: 'discrete', name: 'Discrete Mathematics', code: 'MA301' }
    ],
    '4': [
      { id: 'cn', name: 'Computer Networks', code: 'CS401' },
      { id: 'compiler', name: 'Compiler Design', code: 'CS402' },
      { id: 'software', name: 'Software Engineering', code: 'CS403' },
      { id: 'web', name: 'Web Technologies', code: 'CS404' }
    ],
    '5': [
      { id: 'automata', name: 'Automata Theory', code: 'CS501' },
      { id: 'dbmsadv', name: 'Advanced DBMS', code: 'CS502' },
      { id: 'secure', name: 'Secure Coding Practices', code: 'CS503' },
      { id: 'ml', name: 'Machine Learning', code: 'CS504' },
      { id: 'distributed', name: 'Distributed Systems', code: 'CS505' }
    ],
    '6': [
      { id: 'ai', name: 'Artificial Intelligence', code: 'CS601' },
      { id: 'crypto', name: 'Cryptography & Security', code: 'CS602' },
      { id: 'cloud', name: 'Cloud Computing', code: 'CS603' },
      { id: 'bigdata', name: 'Big Data Analytics', code: 'CS604' }
    ],
    '7': [
      { id: 'blockchain', name: 'Blockchain Technology', code: 'CS701' },
      { id: 'iot', name: 'Internet of Things', code: 'CS702' },
      { id: 'mobile', name: 'Mobile App Development', code: 'CS703' },
      { id: 'project1', name: 'Major Project I', code: 'CS704' }
    ],
    '8': [
      { id: 'ethics', name: 'Professional Ethics', code: 'HS801' },
      { id: 'project2', name: 'Major Project II', code: 'CS801' },
      { id: 'seminar', name: 'Technical Seminar', code: 'CS802' },
      { id: 'internship', name: 'Industrial Training', code: 'CS803' }
    ]
  }), []);

  // Filter subjects based on selected semester
  useEffect(() => {
    if (selectedSemester) {
      const subjects = semesterSubjects[selectedSemester as keyof typeof semesterSubjects] || [];
      setFilteredSubjects(subjects);
      setSelectedSubject('');
      setSelectedFaculty('');
    }
  }, [selectedSemester, semesterSubjects]);

  // Filter faculties based on selected subject
  useEffect(() => {
    if (selectedSubject) {
      // For now, show all faculties since we don't have subject-faculty mapping yet
      // In the future, you can implement proper subject-faculty relationships
      setFilteredFaculties(faculties);
      setSelectedFaculty('');
    }
  }, [selectedSubject, faculties]);

  const handleLogout = () => {
    navigate('/');
  };

  const handleSubmitFeedback = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!selectedSemester) {
      toast({ title: 'Error', description: 'Please select a semester', variant: 'destructive' });
      return;
    }
    if (!selectedSubject) {
      toast({ title: 'Error', description: 'Please select a subject', variant: 'destructive' });
      return;
    }
    if (!selectedFaculty) {
      toast({ title: 'Error', description: 'Please select a faculty', variant: 'destructive' });
      return;
    }
    if (!currentStudent?.id) {
      toast({ title: 'Not logged in', description: 'Please login again', variant: 'destructive' });
      navigate('/student/login');
      return;
    }

    const selectedSubjectInfo = filteredSubjects.find(s => s.id === selectedSubject);
    const feedbackData = {
      studentId: currentStudent.id,
      facultyId: selectedFaculty,
      semester: selectedSemester,
      subjectId: selectedSubject,
      subjectName: selectedSubjectInfo?.name,
      subjectCode: selectedSubjectInfo?.code,
      comment,
      ratings,
    };

    try {
      const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000';
      
      const res = await fetch(`${apiUrl}/api/feedback`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(feedbackData),
      });

      const data = await res.json();

      if (!res.ok) throw new Error(data.error || 'Failed to submit feedback');

      toast({ title: 'Feedback Submitted!', description: '+50 reward points earned' });

      // Reload feedback history
      const historyRes = await fetch(`${apiUrl}/api/students/${currentStudent.id}/feedback`);
      if (historyRes.ok) {
        const historyData = await historyRes.json();
        setFeedbackHistory(historyData);
      }

      // Reset form
      setSelectedSemester('');
      setSelectedSubject('');
      setSelectedFaculty('');
      setRatings({ communication: 5, clarity: 5, knowledge: 5, punctuality: 5, behavior: 5 });
      setComment('');
    } catch (err: unknown) {
      const error = err as Error;
      console.error('Submission error:', error);
      toast({ title: 'Submission Failed', description: error.message || 'Please try again', variant: 'destructive' });
    }
  };

  const rewardPoints = 250;
  const feedbackCount = 5;
  const completionRate = 80;

  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />
      
      <div className="container py-8">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold">Student Dashboard</h1>
            <p className="text-muted-foreground">{currentStudent?.name} - {currentStudent?.usn}</p>
          </div>
          <Button onClick={handleLogout} variant="outline">
            <LogOut className="mr-2 h-4 w-4" />
            Logout
          </Button>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-4 mb-8">
            <TabsTrigger value="dashboard">Dashboard</TabsTrigger>
            <TabsTrigger value="feedback">Submit Feedback</TabsTrigger>
            <TabsTrigger value="history">My Feedback</TabsTrigger>
            <TabsTrigger value="notifications">Notifications</TabsTrigger>
          </TabsList>

          <TabsContent value="dashboard" className="space-y-6">
            <div className="grid gap-6 md:grid-cols-3">
              <DashboardCard
                title="Reward Points"
                value={rewardPoints}
                icon={Award}
                iconColor="text-warning"
                trend="Level 5 - Gold Status"
              />
              <DashboardCard
                title="Feedbacks Submitted"
                value={feedbackCount}
                icon={CheckCircle2}
                iconColor="text-success"
                trend="5 this semester"
              />
              <DashboardCard
                title="Completion Rate"
                value={`${completionRate}%`}
                icon={TrendingUp}
                iconColor="text-primary"
                trend="Almost there!"
              />
            </div>

            <div className="grid gap-6 md:grid-cols-2">
              <Card className="gradient-success text-success-foreground">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Trophy className="h-5 w-5" />
                    Gamification Progress
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <div className="flex items-center justify-between mb-2">
                      <span>Level 5 - Gold</span>
                      <span>{rewardPoints} / 300 pts</span>
                    </div>
                    <Progress value={(rewardPoints / 300) * 100} className="h-3" />
                  </div>
                  <div className="grid grid-cols-3 gap-2">
                    <Badge variant="secondary" className="justify-center py-2">
                      🏆 Active
                    </Badge>
                    <Badge variant="secondary" className="justify-center py-2">
                      ⭐ Timely
                    </Badge>
                    <Badge variant="secondary" className="justify-center py-2">
                      🎯 Consistent
                    </Badge>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Calendar className="h-5 w-5" />
                    Semester Timeline
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  <div className="flex items-center gap-3 p-3 rounded-lg bg-success/10">
                    <CheckCircle2 className="h-5 w-5 text-success" />
                    <div className="flex-1">
                      <p className="text-sm font-semibold">Mid-Semester Feedback</p>
                      <p className="text-xs text-muted-foreground">Completed</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3 p-3 rounded-lg border">
                    <Star className="h-5 w-5 text-warning" />
                    <div className="flex-1">
                      <p className="text-sm font-semibold">End-Semester Feedback</p>
                      <p className="text-xs text-muted-foreground">Due in 2 weeks</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
              
              <div className="mt-4">
                <ChatBot />
              </div>
          </TabsContent>

          <TabsContent value="feedback" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>Submit Faculty Feedback</CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmitFeedback} className="space-y-6">
                  <div className="space-y-2">
                    <Label>Select Semester</Label>
                    <Select value={selectedSemester} onValueChange={setSelectedSemester}>
                      <SelectTrigger>
                        <SelectValue placeholder="Choose semester" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="1">1st Semester</SelectItem>
                        <SelectItem value="2">2nd Semester</SelectItem>
                        <SelectItem value="3">3rd Semester</SelectItem>
                        <SelectItem value="4">4th Semester</SelectItem>
                        <SelectItem value="5">5th Semester</SelectItem>
                        <SelectItem value="6">6th Semester</SelectItem>
                        <SelectItem value="7">7th Semester</SelectItem>
                        <SelectItem value="8">8th Semester</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  {selectedSemester && (
                    <div className="space-y-2">
                      <Label>Select Subject</Label>
                      <Select value={selectedSubject} onValueChange={setSelectedSubject}>
                        <SelectTrigger>
                          <SelectValue placeholder="Choose a subject" />
                        </SelectTrigger>
                        <SelectContent>
                          {filteredSubjects.map((subject) => (
                            <SelectItem key={subject.id} value={subject.id}>
                              {subject.code} - {subject.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  )}

                  {selectedSubject && (
                    <div className="space-y-2">
                      <Label>Select Faculty</Label>
                      <Select value={selectedFaculty} onValueChange={setSelectedFaculty}>
                        <SelectTrigger>
                          <SelectValue placeholder="Choose a faculty member" />
                        </SelectTrigger>
                        <SelectContent>
                          {filteredFaculties.map((faculty) => (
                            <SelectItem key={faculty.id} value={faculty.id}>
                              {faculty.name} - {faculty.department}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  )}

                  <div className="space-y-4">
                    <Label>Rate the Following Parameters (1-5)</Label>
                    
                    {Object.entries(ratings).map(([key, value]) => (
                      <div key={key} className="space-y-2">
                        <div className="flex items-center justify-between">
                          <Label className="capitalize">{key}</Label>
                          <div className="flex gap-1">
                            {[1, 2, 3, 4, 5].map((rating) => (
                              <Button
                                key={rating}
                                type="button"
                                variant={value >= rating ? "default" : "outline"}
                                size="sm"
                                className="h-8 w-8 p-0"
                                onClick={() => setRatings({ ...ratings, [key]: rating })}
                              >
                                {rating === 1 && '😞'}
                                {rating === 2 && '😕'}
                                {rating === 3 && '😐'}
                                {rating === 4 && '🙂'}
                                {rating === 5 && '😊'}
                              </Button>
                            ))}
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="space-y-2">
                    <Label>Additional Comments</Label>
                    <Textarea
                      placeholder="Share your thoughts (optional)"
                      value={comment}
                      onChange={(e) => setComment(e.target.value)}
                      rows={4}
                    />
                  </div>

                  <Button type="submit" className="w-full gradient-success">
                    <CheckCircle2 className="mr-2 h-4 w-4" />
                    Submit Feedback
                  </Button>
                </form>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="history" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>My Feedback History</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {feedbackHistory.length === 0 ? (
                    <div className="text-center py-8 text-muted-foreground">
                      <MessageSquare className="h-12 w-12 mx-auto mb-3 opacity-50" />
                      <p>No feedback submitted yet</p>
                      <p className="text-sm">Submit your first feedback from the "Submit Feedback" tab</p>
                    </div>
                  ) : (
                    feedbackHistory.map((feedback) => (
                      <div
                        key={feedback.id}
                        className="p-4 border rounded-lg hover:bg-accent/50 transition-colors"
                      >
                        <div className="flex items-center justify-between mb-3">
                          <div>
                            <p className="font-semibold">{feedback.faculty.name}</p>
                            <p className="text-sm text-muted-foreground">{feedback.faculty.branch || 'Computer Science'}</p>
                          </div>
                          <Badge>{new Date(feedback.createdAt).toLocaleDateString()}</Badge>
                        </div>
                        <p className="text-sm mb-3">{feedback.comment}</p>
                        <div className="flex gap-2 flex-wrap">
                          <Badge variant="outline">Communication: {feedback.ratings.communication}/5</Badge>
                          <Badge variant="outline">Clarity: {feedback.ratings.clarity}/5</Badge>
                          <Badge variant="outline">Knowledge: {feedback.ratings.knowledge}/5</Badge>
                          <Badge variant="outline">Punctuality: {feedback.ratings.punctuality}/5</Badge>
                          <Badge variant="outline">Behavior: {feedback.ratings.behavior}/5</Badge>
                        </div>
                        {feedback.reply && (
                          <div className="mt-3 p-3 bg-green-50 border border-green-200 rounded">
                            <p className="text-sm font-medium text-green-800 mb-1">Faculty Reply:</p>
                            <p className="text-sm text-green-700">{feedback.reply}</p>
                            <p className="text-xs text-green-600 mt-1">{new Date(feedback.repliedAt).toLocaleDateString()}</p>
                          </div>
                        )}
                      </div>
                    ))
                  )}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="notifications" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Bell className="h-5 w-5" />
                  Notifications & Reminders
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-start gap-3 p-3 rounded-lg border bg-warning/10">
                    <Bell className="h-5 w-5 text-warning mt-0.5" />
                    <div>
                      <p className="font-semibold text-sm">Feedback Reminder</p>
                      <p className="text-xs text-muted-foreground">
                        End-semester feedback deadline is approaching. Submit by Dec 20th.
                      </p>
                      <p className="text-xs text-muted-foreground mt-1">Today</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3 p-3 rounded-lg border">
                    <Award className="h-5 w-5 text-success mt-0.5" />
                    <div>
                      <p className="font-semibold text-sm">Reward Points Earned</p>
                      <p className="text-xs text-muted-foreground">
                        You earned 50 points for timely feedback submission!
                      </p>
                      <p className="text-xs text-muted-foreground mt-1">2 days ago</p>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>

      <Footer />
    </div>
  );
};

export default StudentDashboard;
