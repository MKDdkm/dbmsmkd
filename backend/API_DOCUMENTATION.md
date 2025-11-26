# 🚀 DBMS Feedback System - API Documentation

**Base URL**: `http://localhost:3000`

## 📋 Available API Endpoints

### 1. **Health Check**
- **GET** `/api/health`
- **Description**: Check if API and database are working
- **Response**: 
```json
{
  "ok": true,
  "db": true
}
```

### 2. **Student Login**
- **POST** `/api/login`
- **Description**: Login for students using email or USN
- **Body**:
```json
{
  "email": "mourya@student.scem",  // OR use "usn": "4SC21CS001"
  "password": "student123",
  "role": "student"
}
```
- **Response**:
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "name": "Mourya", 
    "email": "mourya@student.scem",
    "usn": "4SC21CS001"
  }
}
```

### 3. **Faculty Login**
- **POST** `/api/login`
- **Description**: Login for faculty using email
- **Body**:
```json
{
  "email": "vidya@scem.ac.in",
  "password": "faculty123",
  "role": "faculty"
}
```
- **Response**:
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "faculty_id",
    "name": "Vidya V V",
    "email": "vidya@scem.ac.in"
  }
}
```

### 4. **Get Faculty List**
- **GET** `/api/faculty`
- **Description**: Get all faculty members
- **Response**:
```json
[
  {
    "id": "faculty_id",
    "name": "Vidya V V",
    "email": "vidya@scem.ac.in",
    "branch": "CS"
  }
]
```

### 5. **Submit Feedback**
- **POST** `/api/feedback`
- **Description**: Submit feedback for a faculty
- **Body**:
```json
{
  "studentId": "student_id",
  "facultyId": "faculty_id", 
  "comment": "Great teaching style and very helpful",
  "ratings": {
    "teaching": 5,
    "communication": 4,
    "knowledge": 5,
    "availability": 4
  }
}
```
- **Response**:
```json
{
  "ok": true,
  "feedback": {
    "id": "feedback_id",
    "studentId": "student_id",
    "facultyId": "faculty_id",
    "comment": "Great teaching style and very helpful",
    "ratings": {...},
    "sentiment": "positive",
    "createdAt": "2025-11-12T..."
  }
}
```

### 6. **Get Faculty Feedback**
- **GET** `/api/feedback/:facultyId`
- **Description**: Get all feedback for a specific faculty
- **Response**:
```json
[
  {
    "id": "feedback_id",
    "studentId": "student_id", 
    "facultyId": "faculty_id",
    "comment": "Great teacher",
    "ratings": {...},
    "sentiment": "positive",
    "createdAt": "2025-11-12T..."
  }
]
```

## 🔐 Sample Login Credentials

### Students:
- **Email**: `mourya@student.scem` | **USN**: `4SC21CS001` | **Password**: `student123`
- **Email**: `ritesh@student.scem` | **USN**: `4SC21CS002` | **Password**: `student123`
- **Email**: `praneeth@student.scem` | **USN**: `4SC21CS003` | **Password**: `student123`
- **Email**: `mithun@student.scem` | **USN**: `4SC21CS004` | **Password**: `student123`

### Faculty:
- **Email**: `vidya@scem.ac.in` | **Password**: `faculty123`
- **Email**: `ashwini@scem.ac.in` | **Password**: `faculty123`
- **Email**: `srividya@scem.ac.in` | **Password**: `faculty123`
- **Email**: `aparna@scem.ac.in` | **Password**: `faculty123`
- **Email**: `prajwal@scem.ac.in` | **Password**: `faculty123`
- **Email**: `suhas@scem.ac.in` | **Password**: `faculty123`

## 🧪 Testing the APIs

You can test these APIs using:
- **Postman**
- **Thunder Client** (VS Code extension)
- **curl** commands
- **Browser** (for GET requests only)