// 🧪 FRONTEND DATA FLOW TEST
// This shows how frontend data reaches your MySQL database

// ===================================
// 📝 EXAMPLE: Student Registration from Frontend
// ===================================

// Frontend sends this data:
const newStudentData = {
  usn: "4SC21CS005",
  name: "Arjun Kumar", 
  email: "arjun@student.scem",
  password: "student123",
  semester: 5,
  branch: "CS"
};

// API endpoint processes it:
fetch('http://localhost:3000/api/register/student', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(newStudentData)
});

// ===================================
// 💬 EXAMPLE: Feedback Submission from Frontend  
// ===================================

// Frontend sends feedback:
const feedbackData = {
  studentId: "student_id_here",
  facultyId: "faculty_id_here",
  comment: "Excellent teaching! Very clear explanations.",
  ratings: {
    teaching: 5,
    communication: 4, 
    knowledge: 5,
    availability: 4
  }
};

// API endpoint saves it:
fetch('http://localhost:3000/api/feedback', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(feedbackData)
});

// ===================================
// 🔍 IMMEDIATE VISIBILITY
// ===================================

// After frontend submission, you can immediately see the data in:

// 1. MySQL Workbench:
// SELECT * FROM Student ORDER BY id DESC LIMIT 1;
// SELECT * FROM Feedback ORDER BY createdAt DESC LIMIT 1;

// 2. Prisma Studio:
// Refresh the page and see new records

// 3. API Response:
// GET http://localhost:3000/api/students (will include new student)
// GET http://localhost:3000/api/feedback/faculty_id (will show new feedback)