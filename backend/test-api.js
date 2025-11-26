// Test API connectivity
const testLogin = async () => {
  try {
    console.log('Testing API connection...');
    
    // Test health endpoint
    const healthResponse = await fetch('http://localhost:3000/api/health');
    const healthData = await healthResponse.json();
    console.log('Health check:', healthData);
    
    // Test student login
    const loginResponse = await fetch('http://localhost:3000/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        role: 'student', 
        usn: '4SC21CS001', 
        password: 'student123' 
      })
    });
    
    const loginData = await loginResponse.json();
    console.log('Login response:', loginData);
    console.log('Status:', loginResponse.status, loginResponse.ok);
    
  } catch (error) {
    console.error('Test error:', error);
  }
};

testLogin();