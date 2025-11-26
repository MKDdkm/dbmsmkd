import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const students = [
    { usn: '4SC21CS001', name: 'Mourya', email: 'mourya@student.scem', password: await bcrypt.hash('student123', 10), semester: 5, branch: 'CS' },
    { usn: '4SC21CS002', name: 'Ritesh', email: 'ritesh@student.scem', password: await bcrypt.hash('student123', 10), semester: 5, branch: 'CS' },
    { usn: '4SC21CS003', name: 'Praneeth', email: 'praneeth@student.scem', password: await bcrypt.hash('student123', 10), semester: 5, branch: 'CS' },
    { usn: '4SC21CS004', name: 'Mithun', email: 'mithun@student.scem', password: await bcrypt.hash('student123', 10), semester: 5, branch: 'CS' },
  ];

  const faculties = [
    { name: 'Vidya VV', email: 'vidya@scem.ac.in', password: await bcrypt.hash('vidya123', 10), branch: 'CS' },
    { name: 'Ashwini CS', email: 'ashwini@scem.ac.in', password: await bcrypt.hash('faculty123', 10), branch: 'CS' },
    { name: 'Srividya Bhat', email: 'srividya@scem.ac.in', password: await bcrypt.hash('faculty123', 10), branch: 'CS' },
    { name: 'Aparna', email: 'aparna@scem.ac.in', password: await bcrypt.hash('faculty123', 10), branch: 'CS' },
    { name: 'Prajwal', email: 'prajwal@scem.ac.in', password: await bcrypt.hash('faculty123', 10), branch: 'CS' },
    { name: 'Test Faculty', email: 'test@scem.ac.in', password: await bcrypt.hash('123', 10), branch: 'CS' },
    { name: 'Demo Faculty', email: 'demo@scem.ac.in', password: await bcrypt.hash('demo', 10), branch: 'CS' },
    { name: 'Faculty User', email: 'faculty@scem.ac.in', password: await bcrypt.hash('faculty', 10), branch: 'CS' },
  ];

  await prisma.student.createMany({ data: students, skipDuplicates: true });
  await prisma.faculty.createMany({ data: faculties, skipDuplicates: true });
}

main()
  .then(async () => {
    await prisma.$disconnect();
    console.log('Seed complete');
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });