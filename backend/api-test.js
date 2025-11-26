// Quick API Test Script
// Run this with: node api-test.js

const http = require('http');

function testAPI() {
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/health',
    method: 'GET'
  };

  const req = http.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });
    res.on('end', () => {
      console.log('✅ API Response:', data);
    });
  });

  req.on('error', (error) => {
    console.log('❌ API Error:', error.message);
  });

  req.end();
}

// Test after 2 seconds to give server time to start
setTimeout(testAPI, 2000);
console.log('🔍 Testing API connection...');