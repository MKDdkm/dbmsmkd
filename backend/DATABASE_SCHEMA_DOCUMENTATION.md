# 📊 DATABASE SCHEMA DOCUMENTATION
## Smart Feedback Management System - SCEM

---

## 🗂️ **DATABASE TABLES STRUCTURE**

### **Database Name:** `feedback_system`
**Total Tables:** 6 (3 Main + 3 Support)

---

## 📋 **MAIN TABLES**

### **1. Student Table**

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | VARCHAR(191) | PRIMARY KEY | Unique student identifier (CUID) |
| usn | VARCHAR(191) | UNIQUE, NOT NULL | University Seat Number |
| name | VARCHAR(255) | NOT NULL | Student full name |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Student email address |
| password | VARCHAR(255) | NOT NULL | Hashed password |
| semester | INT | NOT NULL, CHECK (1-8) | Current semester (1 to 8) |
| branch | VARCHAR(100) | NOT NULL | Department/Branch (e.g., CSE, ISE) |

**Constraints:**
- `CHECK (semester >= 1 AND semester <= 8)`
- `CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')`
- `CHECK (usn REGEXP '^[0-9][A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{3}$')`

**Sample Data:**
```
id: clh8k2j3d0001xyz
usn: 1SI22CS001
name: Mourya Moger
email: mourya@scem.ac.in
semester: 5
branch: CSE
```

---

### **2. Faculty Table**

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | VARCHAR(191) | PRIMARY KEY | Unique faculty identifier (CUID) |
| name | VARCHAR(255) | NOT NULL | Faculty full name |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Faculty email address |
| password | VARCHAR(255) | NOT NULL | Hashed password |
| branch | VARCHAR(100) | NOT NULL | Department (e.g., Computer Science) |

**Constraints:**
- `CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')`
- `CHECK (CHAR_LENGTH(name) >= 2 AND CHAR_LENGTH(name) <= 100)`

**Sample Data:**
```
id: clh8k2j3d0002xyz
name: Dr. Vidya Shetty
email: vidya@scem.ac.in
branch: Computer Science
```

---

### **3. Feedback Table** (Central Transaction Table)

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | VARCHAR(191) | PRIMARY KEY | Unique feedback identifier (CUID) |
| studentId | VARCHAR(191) | FOREIGN KEY → Student(id) | Reference to student |
| facultyId | VARCHAR(191) | FOREIGN KEY → Faculty(id) | Reference to faculty |
| comment | TEXT | NOT NULL | Feedback text/comment |
| ratings | JSON | NOT NULL | Rating object with 5 categories |
| sentiment | VARCHAR(20) | NOT NULL | Auto-calculated: positive/neutral/negative |
| reply | TEXT | NULL | Faculty reply to feedback |
| repliedAt | DATETIME | NULL | Timestamp when faculty replied |
| createdAt | DATETIME | DEFAULT NOW() | Feedback submission timestamp |

**Ratings JSON Structure:**
```json
{
  "communication": 5,
  "clarity": 4,
  "knowledge": 5,
  "punctuality": 4,
  "behavior": 5
}
```

**Constraints:**
- Each rating value: 1-5 (validated by trigger)
- Sentiment auto-calculated by trigger based on average rating
- `FOREIGN KEY (studentId) REFERENCES Student(id)`
- `FOREIGN KEY (facultyId) REFERENCES Faculty(id)`

**Sample Data:**
```
id: clh8k2j3d0003xyz
studentId: clh8k2j3d0001xyz
facultyId: clh8k2j3d0002xyz
comment: "Excellent professor! Clear explanations."
ratings: {"communication": 5, "clarity": 5, "knowledge": 5, "punctuality": 5, "behavior": 5}
sentiment: positive
reply: "Thank you for your feedback!"
repliedAt: 2025-11-24 15:30:00
createdAt: 2025-11-23 10:45:00
```

---

## 🔧 **SUPPORT TABLES** (For Advanced Features)

### **4. Feedback_Stats Table** (Materialized View)

| Column Name | Data Type | Description |
|------------|-----------|-------------|
| id | INT | PRIMARY KEY AUTO_INCREMENT |
| faculty_id | VARCHAR(191) | Reference to Faculty |
| total_feedbacks | INT | Total feedback count |
| overall_average | DECIMAL(3,2) | Average rating (1-5) |
| avg_communication_rating | DECIMAL(3,2) | Avg communication score |
| avg_clarity_rating | DECIMAL(3,2) | Avg clarity score |
| avg_knowledge_rating | DECIMAL(3,2) | Avg knowledge score |
| avg_punctuality_rating | DECIMAL(3,2) | Avg punctuality score |
| avg_behavior_rating | DECIMAL(3,2) | Avg behavior score |
| positive_count | INT | Number of positive feedbacks |
| neutral_count | INT | Number of neutral feedbacks |
| negative_count | INT | Number of negative feedbacks |
| last_updated | TIMESTAMP | Auto-updated by trigger |

**Purpose:** Pre-calculated statistics for faster dashboard loading

---

### **5. Faculty_Audit Table** (Audit Trail)

| Column Name | Data Type | Description |
|------------|-----------|-------------|
| audit_id | INT | PRIMARY KEY AUTO_INCREMENT |
| faculty_id | VARCHAR(191) | Faculty being audited |
| action_type | ENUM | 'INSERT', 'UPDATE', 'DELETE' |
| old_name | VARCHAR(255) | Previous name value |
| new_name | VARCHAR(255) | New name value |
| old_email | VARCHAR(255) | Previous email value |
| new_email | VARCHAR(255) | New email value |
| old_branch | VARCHAR(255) | Previous branch value |
| new_branch | VARCHAR(255) | New branch value |
| changed_by | VARCHAR(255) | MySQL user who made change |
| change_timestamp | TIMESTAMP | When change occurred |

**Purpose:** Track all changes to faculty records for compliance

---

### **6. Student_Activity_Log Table** (Activity Tracking)

| Column Name | Data Type | Description |
|------------|-----------|-------------|
| log_id | INT | PRIMARY KEY AUTO_INCREMENT |
| student_id | VARCHAR(191) | Student performing action |
| activity_type | VARCHAR(50) | Type of activity (LOGIN, FEEDBACK_SUBMIT, etc.) |
| activity_details | TEXT | Additional details |
| ip_address | VARCHAR(45) | User IP address |
| activity_timestamp | TIMESTAMP | When activity occurred |

**Purpose:** Monitor student engagement and system usage

---

## 🔗 **RELATIONSHIPS (ER Diagram)**

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Student   │         │  Feedback   │         │   Faculty   │
│─────────────│         │─────────────│         │─────────────│
│ id (PK)     │───────┐ │ id (PK)     │ ┌───────│ id (PK)     │
│ usn         │       └─│ studentId(FK)│─┘       │ name        │
│ name        │         │ facultyId(FK)│─┐       │ email       │
│ email       │         │ comment     │ │       │ password    │
│ password    │         │ ratings     │ │       │ branch      │
│ semester    │         │ sentiment   │ │       └─────────────┘
│ branch      │         │ reply       │ │              │
└─────────────┘         │ repliedAt   │ │              │
       │                │ createdAt   │ │              │
       │                └─────────────┘ │              │
       │                       │         │              │
       │                       │         │              │
       └───────────────────────┴─────────┴──────────────┘
                       1:N Relationships
```

**Cardinality:**
- One Student can give MANY Feedbacks (1:N)
- One Faculty can receive MANY Feedbacks (1:N)
- One Feedback belongs to ONE Student and ONE Faculty (N:1)

---

## 🎯 **RELATIONAL SCHEMA MAPPING**

### **From ER to Relational Schema:**

**Entities → Tables:**
- `Student` entity → `Student` table
- `Faculty` entity → `Faculty` table
- `Feedback` entity → `Feedback` table (relationship entity)

**Relationships:**
- `gives_feedback` (Student → Feedback): Implemented as `studentId` foreign key in Feedback
- `receives_feedback` (Faculty → Feedback): Implemented as `facultyId` foreign key in Feedback

**Attributes:**
- Simple attributes → Regular columns
- Composite attributes: None (all are simple)
- Multi-valued attribute (`ratings`): Stored as JSON
- Derived attributes (`sentiment`): Auto-calculated by trigger

---

## 📐 **NORMALIZATION LEVEL**

**Current Normalization: 3NF (Third Normal Form)**

✅ **1NF:** All attributes contain atomic values (JSON is treated as single unit)
✅ **2NF:** No partial dependencies (all non-key attributes depend on entire primary key)
✅ **3NF:** No transitive dependencies (no non-key attribute depends on another non-key attribute)

**Why JSON for ratings?**
- Flexibility: Easy to add new rating categories
- Performance: Single column instead of 5 separate columns
- Querying: MySQL supports JSON functions (JSON_EXTRACT)

---

## 🔑 **KEYS AND INDEXES**

### **Primary Keys:**
- `Student.id`
- `Faculty.id`
- `Feedback.id`
- `Feedback_Stats.id`
- `Faculty_Audit.audit_id`
- `Student_Activity_Log.log_id`

### **Foreign Keys:**
- `Feedback.studentId` → `Student.id` (ON DELETE CASCADE)
- `Feedback.facultyId` → `Faculty.id` (ON DELETE CASCADE)

### **Unique Keys:**
- `Student.usn`
- `Student.email`
- `Faculty.email`

### **Recommended Indexes:**
```sql
CREATE INDEX idx_feedback_student ON Feedback(studentId);
CREATE INDEX idx_feedback_faculty ON Feedback(facultyId);
CREATE INDEX idx_feedback_sentiment ON Feedback(sentiment);
CREATE INDEX idx_feedback_created ON Feedback(createdAt);
CREATE INDEX idx_student_branch ON Student(branch);
CREATE INDEX idx_faculty_branch ON Faculty(branch);
```

---

## 📊 **DATA DICTIONARY**

### **Domain Definitions:**

| Domain | Data Type | Range/Format | Example |
|--------|-----------|--------------|---------|
| StudentID | CUID | 25 characters | clh8k2j3d0001xyz |
| FacultyID | CUID | 25 characters | clh8k2j3d0002xyz |
| USN | String | `1SI22CS001` format | 1SI22CS001 |
| Email | String | `user@domain.com` | mourya@scem.ac.in |
| Semester | Integer | 1-8 | 5 |
| Rating | Integer | 1-5 | 4 |
| Sentiment | Enum | positive/neutral/negative | positive |
| Branch | String | CSE/ISE/ECE/etc. | CSE |

---

## 🎨 **SCHEMA DIAGRAM (Text Format)**

```
STUDENT                          FEEDBACK                         FACULTY
┌──────────────────┐            ┌──────────────────┐            ┌──────────────────┐
│ PK: id           │◄───────────│ PK: id           │───────────►│ PK: id           │
│ UK: usn          │            │ FK: studentId    │            │ UK: email        │
│ UK: email        │            │ FK: facultyId    │            │     name         │
│     name         │            │     comment      │            │     password     │
│     password     │            │     ratings(JSON)│            │     branch       │
│     semester     │            │     sentiment    │            └──────────────────┘
│     branch       │            │     reply        │                     │
└──────────────────┘            │     repliedAt    │                     │
        │                       │     createdAt    │                     │
        │                       └──────────────────┘                     │
        │                                │                               │
        │                                │                               │
        └────────────────────────────────┴───────────────────────────────┘
                            Feedback Stats Table
                        ┌────────────────────────┐
                        │ faculty_id (FK)        │
                        │ total_feedbacks        │
                        │ overall_average        │
                        │ avg_communication      │
                        │ avg_clarity            │
                        │ avg_knowledge          │
                        │ avg_punctuality        │
                        │ avg_behavior           │
                        │ positive_count         │
                        │ negative_count         │
                        │ last_updated           │
                        └────────────────────────┘
```

---

## 🔥 **TRIGGERS SUMMARY**

1. **update_feedback_sentiment** (BEFORE INSERT on Feedback)
   - Auto-calculates sentiment based on average rating

2. **update_feedback_stats** (AFTER INSERT on Feedback)
   - Updates Feedback_Stats table with new statistics

3. **faculty_audit_update** (AFTER UPDATE on Faculty)
   - Logs all faculty record changes to Faculty_Audit

4. **prevent_faculty_delete** (BEFORE DELETE on Faculty)
   - Prevents deletion if faculty has active feedbacks

---

## 💾 **SAMPLE SQL CREATE STATEMENTS**

```sql
CREATE DATABASE feedback_system;
USE feedback_system;

-- Main Tables
CREATE TABLE Student (
    id VARCHAR(191) PRIMARY KEY,
    usn VARCHAR(191) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    semester INT NOT NULL CHECK (semester BETWEEN 1 AND 8),
    branch VARCHAR(100) NOT NULL
);

CREATE TABLE Faculty (
    id VARCHAR(191) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    branch VARCHAR(100) NOT NULL
);

CREATE TABLE Feedback (
    id VARCHAR(191) PRIMARY KEY,
    studentId VARCHAR(191) NOT NULL,
    facultyId VARCHAR(191) NOT NULL,
    comment TEXT NOT NULL,
    ratings JSON NOT NULL,
    sentiment VARCHAR(20) NOT NULL,
    reply TEXT,
    repliedAt DATETIME,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (studentId) REFERENCES Student(id) ON DELETE CASCADE,
    FOREIGN KEY (facultyId) REFERENCES Faculty(id) ON DELETE CASCADE
);

-- Support Tables
CREATE TABLE Feedback_Stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id VARCHAR(191) UNIQUE,
    total_feedbacks INT DEFAULT 0,
    overall_average DECIMAL(3,2) DEFAULT 0,
    avg_communication_rating DECIMAL(3,2),
    avg_clarity_rating DECIMAL(3,2),
    avg_knowledge_rating DECIMAL(3,2),
    avg_punctuality_rating DECIMAL(3,2),
    avg_behavior_rating DECIMAL(3,2),
    positive_count INT DEFAULT 0,
    neutral_count INT DEFAULT 0,
    negative_count INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Faculty_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id VARCHAR(191),
    action_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    old_name VARCHAR(255),
    new_name VARCHAR(255),
    old_email VARCHAR(255),
    new_email VARCHAR(255),
    old_branch VARCHAR(255),
    new_branch VARCHAR(255),
    changed_by VARCHAR(255),
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📈 **CURRENT DATABASE STATISTICS**

| Metric | Value |
|--------|-------|
| Total Students | 4+ |
| Total Faculty | 8+ |
| Total Feedbacks | 10+ |
| Avg System Rating | 4.2/5.0 |
| Positive Feedback % | 75% |
| Database Size | ~5 MB |

---

## 🎯 **FOR DRAWING DIAGRAMS**

**Recommended Tools:**
- **ER Diagram:** Draw.io, Lucidchart, dbdiagram.io
- **Schema Diagram:** MySQL Workbench (reverse engineer), DBeaver
- **Quick Online:** dbdiagram.io (paste schema code)

**Quick dbdiagram.io Code:**
```
Table Student {
  id varchar(191) [pk]
  usn varchar(191) [unique]
  name varchar(255)
  email varchar(255) [unique]
  password varchar(255)
  semester int
  branch varchar(100)
}

Table Faculty {
  id varchar(191) [pk]
  name varchar(255)
  email varchar(255) [unique]
  password varchar(255)
  branch varchar(100)
}

Table Feedback {
  id varchar(191) [pk]
  studentId varchar(191) [ref: > Student.id]
  facultyId varchar(191) [ref: > Faculty.id]
  comment text
  ratings json
  sentiment varchar(20)
  reply text
  repliedAt datetime
  createdAt datetime
}

Table Feedback_Stats {
  id int [pk]
  faculty_id varchar(191) [ref: - Faculty.id]
  total_feedbacks int
  overall_average decimal
  positive_count int
  negative_count int
  last_updated timestamp
}
```

**Copy the code above to:** https://dbdiagram.io/d

---

**End of Schema Documentation** 🎓
