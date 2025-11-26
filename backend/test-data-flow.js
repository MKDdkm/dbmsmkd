// 🧪 Quick API Test - Add Data and Verify
// Run this to test if frontend data flows to database

async function testDataFlow() {
  const baseURL = 'http://localhost:3000';
  
  try {
    // 1. Test if server is running
    console.log('🔍 Testing server connection...');
    const healthResponse = await fetch(`${baseURL}/api/health`);
    console.log('✅ Server Status:', await healthResponse.json());
    
    // 2. Add sample feedback via API
    console.log('📝 Adding sample feedback...');
    const feedbackData = {
      studentId: "clx1sample001", // Sample ID
      facultyId: "clx2sample001", // Sample ID  
      comment: "Added via API test - excellent teaching!",
      ratings: {
        teaching: 5,
        communication: 4,
        knowledge: 5,
        availability: 4
      }
    };
    
    const feedbackResponse = await fetch(`${baseURL}/api/feedback`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(feedbackData)
    });
    
    if (feedbackResponse.ok) {
      const result = await feedbackResponse.json();
      console.log('✅ Feedback Added:', result);
      console.log('🎯 Now check MySQL Workbench or Prisma Studio!');
    } else {
      console.log('❌ Feedback failed:', await feedbackResponse.text());
    }
    
    // 3. Get faculty list to verify database connectivity
    console.log('📋 Fetching faculty list...');
    const facultyResponse = await fetch(`${baseURL}/api/faculty`);
    const faculty = await facultyResponse.json();
    console.log('👩‍🏫 Faculty Count:', faculty.length);
    
  } catch (error) {
    console.error('❌ Test Error:', error.message);
  }
}

// Run the test
testDataFlow();