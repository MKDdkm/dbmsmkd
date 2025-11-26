import express from 'express';
import cors from 'cors';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import 'dotenv/config';

const app = express();
const prisma = new PrismaClient();
app.use(cors());
app.use(express.json());

app.get('/api/health', (_req, res) => {
  res.json({ ok: true, db: !!process.env.DATABASE_URL });
});

// Login endpoint (student or faculty based on role)
app.post('/api/login', async (req, res) => {
  try {
    const { email, usn, password, role } = req.body as { email?: string; usn?: string; password: string; role: 'student' | 'faculty' };
    if (!password || !role) return res.status(400).json({ error: 'Missing password/role' });

    if (role === 'student') {
      if (!email && !usn) return res.status(400).json({ error: 'Provide email or usn' });
      const user = email
        ? await prisma.student.findUnique({ where: { email } })
        : await prisma.student.findUnique({ where: { usn: usn! } });
      if (!user || !bcrypt.compareSync(password, user.password)) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
      const token = jwt.sign({ id: user.id, role }, process.env.JWT_SECRET!, { expiresIn: '7d' });
      return res.json({ token, user: { id: user.id, name: user.name, email: user.email, usn: user.usn } });
    } else {
      if (!email) return res.status(400).json({ error: 'Faculty login requires email' });
      const user = await prisma.faculty.findUnique({ where: { email } });
      if (!user || !bcrypt.compareSync(password, user.password)) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
      const token = jwt.sign({ id: user.id, role }, process.env.JWT_SECRET!, { expiresIn: '7d' });
      return res.json({ token, user: { id: user.id, name: user.name, email: user.email } });
    }
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

// Fetch faculty list
app.get('/api/faculty', async (_req, res) => {
  const list = await prisma.faculty.findMany();
  res.json(list);
});

// Get total student count
app.get('/api/students/count', async (_req, res) => {
  try {
    const count = await prisma.student.count();
    res.json({ count });
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

// Get feedback by student ID
app.get('/api/students/:studentId/feedback', async (req, res) => {
  try {
    const { studentId } = req.params;
    const feedbacks = await prisma.feedback.findMany({
      where: {
        studentId: studentId
      },
      include: {
        faculty: {
          select: {
            id: true,
            name: true,
            email: true,
            branch: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });
    res.json(feedbacks);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

// Get recent feedback endpoint
app.get('/api/feedback/recent', async (req, res) => {
  try {
    const { days = 7, limit = 50 } = req.query;
    const daysNum = parseInt(days as string) || 7;
    const limitNum = parseInt(limit as string) || 50;
    
    const recentFeedback = await prisma.feedback.findMany({
      where: {
        createdAt: {
          gte: new Date(Date.now() - daysNum * 24 * 60 * 60 * 1000)
        }
      },
      include: {
        student: {
          select: {
            name: true,
            usn: true,
            semester: true,
            branch: true,
            email: true
          }
        },
        faculty: {
          select: {
            name: true,
            branch: true,
            email: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      },
      take: limitNum
    });

    res.json({
      success: true,
      count: recentFeedback.length,
      data: recentFeedback
    });
  } catch (error: any) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Get feedback statistics
app.get('/api/feedback/stats', async (req, res) => {
  try {
    const { days = 7 } = req.query;
    const daysNum = parseInt(days as string) || 7;
    const startDate = new Date(Date.now() - daysNum * 24 * 60 * 60 * 1000);
    
    const totalCount = await prisma.feedback.count({
      where: { createdAt: { gte: startDate } }
    });
    
    const uniqueFaculties = await prisma.feedback.groupBy({
      by: ['facultyId'],
      where: { createdAt: { gte: startDate } },
      _count: true
    });
    
    const uniqueStudents = await prisma.feedback.groupBy({
      by: ['studentId'],
      where: { createdAt: { gte: startDate } },
      _count: true
    });

    res.json({
      success: true,
      period: `Last ${daysNum} days`,
      statistics: {
        totalFeedback: totalCount,
        activeFaculties: uniqueFaculties.length,
        activeStudents: uniqueStudents.length,
        averageFeedbackPerFaculty: uniqueFaculties.length > 0 ? totalCount / uniqueFaculties.length : 0
      }
    });
  } catch (error: any) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Get today's feedback
app.get('/api/feedback/today', async (_req, res) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const endOfDay = new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000);
    
    const todaysFeedback = await prisma.feedback.findMany({
      where: {
        createdAt: {
          gte: startOfDay,
          lt: endOfDay
        }
      },
      include: {
        student: {
          select: {
            name: true,
            usn: true,
            semester: true,
            branch: true
          }
        },
        faculty: {
          select: {
            name: true,
            branch: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json({
      success: true,
      date: startOfDay.toISOString().split('T')[0],
      count: todaysFeedback.length,
      data: todaysFeedback
    });
  } catch (error: any) {
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Submit feedback
app.post('/api/feedback', async (req, res) => {
  try {
    const { 
      studentId, 
      facultyId, 
      semester,
      subjectId,
      subjectName,
      subjectCode,
      comment, 
      ratings 
    } = req.body as any;
    
    if (!studentId || !facultyId) {
      return res.status(400).json({ error: 'Missing required fields: studentId or facultyId' });
    }
    
    const sentiment = 'positive'; // You can implement actual sentiment analysis here
    
    // For now, save basic feedback data (semester/subject info can be stored in comment)
    const enhancedComment = comment ? 
      `${comment} [Semester: ${semester}, Subject: ${subjectName} (${subjectCode})]` : 
      `[Semester: ${semester}, Subject: ${subjectName} (${subjectCode})]`;
    
    const created = await prisma.feedback.create({
      data: {
        studentId,
        facultyId,
        comment: enhancedComment,
        ratings: ratings || {},
        sentiment
      },
    });
    
    res.json({ ok: true, feedback: created, message: 'Feedback submitted successfully!' });
  } catch (e: any) {
    console.error('❌ Feedback submission error:', e);
    res.status(500).json({ error: e.message });
  }
});

// Get feedback for a faculty
app.get('/api/feedback/:facultyId', async (req, res) => {
  const { facultyId } = req.params;
  const list = await prisma.feedback.findMany({ where: { facultyId }, orderBy: { createdAt: 'desc' } });
  res.json(list);
});

// Faculty reply to feedback
app.post('/api/feedback/:feedbackId/reply', async (req, res) => {
  try {
    const { feedbackId } = req.params;
    const { reply } = req.body as { reply: string };
    
    if (!reply) {
      return res.status(400).json({ error: 'Reply message is required' });
    }
    
    const updated = await prisma.feedback.update({
      where: { id: feedbackId },
      data: {
        reply,
        repliedAt: new Date()
      },
      include: {
        student: { select: { name: true, email: true } },
        faculty: { select: { name: true } }
      }
    });
    
    res.json({ ok: true, feedback: updated, message: 'Reply sent successfully!' });
  } catch (e: any) {
    console.error('❌ Reply error:', e);
    res.status(500).json({ error: e.message });
  }
});

// Get feedback for a faculty with student details (for faculty dashboard)
app.get('/api/faculty/:facultyId/feedback', async (req, res) => {
  try {
    const { facultyId } = req.params;
    const feedbackList = await prisma.feedback.findMany({
      where: { facultyId },
      include: {
        student: {
          select: {
            id: true,
            usn: true,
            name: true,
            email: true,
            semester: true,
            branch: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
    res.json(feedbackList);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

// Export all feedback to CSV format (can be opened in Excel)
app.get('/api/export/feedback', async (_req, res) => {
  try {
    const feedbackList = await prisma.feedback.findMany({
      include: {
        student: {
          select: { name: true, usn: true, email: true, semester: true, branch: true }
        },
        faculty: {
          select: { name: true, email: true, branch: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    // Create CSV content
    const csvHeader = 'Student Name,USN,Student Email,Semester,Branch,Faculty Name,Faculty Email,Faculty Department,Comment,Sentiment,Submitted At\n';
    const csvRows = feedbackList.map(f => {
      const comment = (f.comment || '').replace(/"/g, '""').replace(/\n/g, ' ');
      return `"${f.student.name}","${f.student.usn}","${f.student.email}","${f.student.semester}","${f.student.branch}","${f.faculty.name}","${f.faculty.email}","${f.faculty.branch}","${comment}","${f.sentiment}","${f.createdAt.toISOString()}"`;
    }).join('\n');
    
    const csv = csvHeader + csvRows;
    
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=feedback_report.csv');
    res.send(csv);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

const port = process.env.PORT ? Number(process.env.PORT) : 4000;
app.listen(port, () => console.log(`API running on http://localhost:${port}`));