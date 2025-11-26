export interface Faculty {
  id: string;
  name: string;
  email: string;
  department: string;
  subjects: string[];
  experience: number;
  rating: number;
  totalFeedbacks: number;
}

export interface Student {
  id: string;
  name: string;
  email: string;
  usn: string;
  department: string;
  semester: number;
  rewardPoints: number;
}

export interface Feedback {
  id: string;
  studentId: string;
  facultyId: string;
  ratings: {
    communication: number;
    clarity: number;
    knowledge: number;
    punctuality: number;
    behavior: number;
  };
  comment: string;
  sentiment: 'positive' | 'neutral' | 'negative';
  date: string;
}

export const mockFaculties: Faculty[] = [
  {
    id: 'F001',
    name: 'Vidya V V',
    email: 'vidya.vv@scem.ac.in',
    department: 'Computer Science',
    subjects: ['Data Structures', 'Algorithms'],
    experience: 10,
    rating: 4.6,
    totalFeedbacks: 160
  },
  {
    id: 'F002',
    name: 'Ashwini C S',
    email: 'ashwini.cs@scem.ac.in',
    department: 'Computer Science',
    subjects: ['Web Development', 'Database Systems'],
    experience: 7,
    rating: 4.7,
    totalFeedbacks: 140
  },
  {
    id: 'F003',
    name: 'Srividya Bhat',
    email: 'srividya.bhat@scem.ac.in',
    department: 'Computer Science',
    subjects: ['Algorithms', 'Database Systems'],
    experience: 9,
    rating: 4.5,
    totalFeedbacks: 135
  },
  {
    id: 'F004',
    name: 'Aparna',
    email: 'aparna@scem.ac.in',
    department: 'Computer Science',
    subjects: ['Web Development', 'Data Structures'],
    experience: 6,
    rating: 4.4,
    totalFeedbacks: 120
  },
  {
    id: 'F005',
    name: 'Prajwal',
    email: 'prajwal@scem.ac.in',
    department: 'Computer Science',
    subjects: ['Data Structures', 'Algorithms'],
    experience: 4,
    rating: 4.2,
    totalFeedbacks: 95
  },
  {
    id: 'F006',
    name: 'Suhas',
    email: 'suhas@scem.ac.in',
    department: 'Computer Science',
    subjects: ['Database Systems', 'Web Development'],
    experience: 5,
    rating: 4.3,
    totalFeedbacks: 110
  },
];

export const mockStudents: Student[] = [
  {
    id: 'S001',
    name: 'Mourya',
    email: 'mourya@scem.ac.in',
    usn: '4SC21CS001',
    department: 'Computer Science',
    semester: 5,
    rewardPoints: 250
  },
  {
    id: 'S002',
    name: 'Ritesh',
    email: 'ritesh@scem.ac.in',
    usn: '4SC21CS042',
    department: 'Computer Science',
    semester: 5,
    rewardPoints: 320
  },
  {
    id: 'S003',
    name: 'Praneeth',
    email: 'praneeth@scem.ac.in',
    usn: '4SC21CS087',
    department: 'Computer Science',
    semester: 5,
    rewardPoints: 180
  },
  {
    id: 'S004',
    name: 'Mithun',
    email: 'mithun@scem.ac.in',
    usn: '4SC21CS105',
    department: 'Computer Science',
    semester: 5,
    rewardPoints: 210
  },
];

export const mockFeedbacks: Feedback[] = [
  {
    id: 'FB001',
    studentId: 'S001',
    facultyId: 'F001',
    ratings: {
      communication: 5,
      clarity: 4,
      knowledge: 5,
      punctuality: 4,
      behavior: 5
    },
    comment: 'Excellent teaching methodology and very supportive. Explains concepts clearly.',
    sentiment: 'positive',
    date: '2024-10-15'
  },
  {
    id: 'FB002',
    studentId: 'S002',
    facultyId: 'F002',
    ratings: {
      communication: 5,
      clarity: 5,
      knowledge: 5,
      punctuality: 5,
      behavior: 5
    },
    comment: 'Outstanding professor! Makes complex topics easy to understand.',
    sentiment: 'positive',
    date: '2024-10-18'
  },
  {
    id: 'FB003',
    studentId: 'S003',
    facultyId: 'F003',
    ratings: {
      communication: 4,
      clarity: 4,
      knowledge: 4,
      punctuality: 4,
      behavior: 4
    },
    comment: 'Classes are engaging and well-structured. Explanations are clear and supportive. Overall, excellent delivery.',
    sentiment: 'positive',
    date: '2024-10-20'
  },
  {
    id: 'FB004',
    studentId: 'S004',
    facultyId: 'F004',
    ratings: {
      communication: 4,
      clarity: 5,
      knowledge: 4,
      punctuality: 4,
      behavior: 5
    },
    comment: 'Great practical sessions and project guidance.',
    sentiment: 'positive',
    date: '2024-11-01'
  },
];

export const departments = [
  'Computer Science',
  'Electronics',
  'Mechanical',
  'Civil',
  'Information Science',
];

export const subjects = [
  'Data Structures',
  'Algorithms',
  'Web Development',
  'Database Systems',
  'Digital Electronics',
  'VLSI Design',
  'Thermodynamics',
  'Fluid Mechanics',
];
