import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // Load test plan
  stages: [
    { duration: '30s', target: 20 }, // Reach 20 users in the first 15 seconds (Warm-up)
    { duration: '2m', target: 100 }, // Reach 100 users in the next 1 minute (Load)
    { duration: '30s', target: 0 },  // Gradually go back to 0 users (Cool-down)
  ],
};

const serviceIP = __ENV.SERVICE_IP || 'localhost';

export default function () {
  // Each virtual user makes a GET request to the /heavy endpoint
  http.get(`http://${serviceIP}/heavy`);
  sleep(1); // Each user waits 1 second before making the next request
}
