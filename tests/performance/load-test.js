import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  scenarios: {
    cluster_operations: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 10 },  // Ramp-up
        { duration: '5m', target: 10 },  // Stay at peak
        { duration: '2m', target: 0 },   // Ramp-down
      ],
      gracefulRampDown: '30s',
    },
    api_endpoints: {
      executor: 'constant-arrival-rate',
      rate: 100,
      timeUnit: '1s',
      duration: '10m',
      preAllocatedVUs: 20,
      maxVUs: 50,
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should complete within 500ms
    errors: ['rate<0.1'],            // Error rate should be less than 10%
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:8080';
const API_TOKEN = __ENV.API_TOKEN || 'test-token';

export function setup() {
  const loginRes = http.post(`${BASE_URL}/auth/login`, {
    username: __ENV.USERNAME || 'test-user',
    password: __ENV.PASSWORD || 'test-password',
  });
  return { token: loginRes.json('token') };
}

export default function(data) {
  const headers = {
    'Authorization': `Bearer ${data.token}`,
    'Content-Type': 'application/json',
  };

  const responses = {
    clusters: http.get(`${BASE_URL}/api/clusters`, { headers }),
    deployments: http.get(`${BASE_URL}/api/deployments`, { headers }),
    metrics: http.get(`${BASE_URL}/api/metrics`, { headers }),
  };

  // Create a new cluster
  const createClusterRes = http.post(`${BASE_URL}/api/clusters`, JSON.stringify({
    name: `test-cluster-${Date.now()}`,
    provider: 'aws',
    region: 'us-west-2',
    nodeCount: 3,
  }), { headers });

  Object.keys(responses).forEach(endpoint => {
    const success = check(responses[endpoint], {
      [`${endpoint} status is 200`]: (r) => r.status === 200,
      [`${endpoint} response time < 500ms`]: (r) => r.timings.duration < 500,
    });
    errorRate.add(!success);
  });

  check(createClusterRes, {
    'cluster creation successful': (r) => r.status === 201,
    'cluster creation time < 2s': (r) => r.timings.duration < 2000,
  });

  sleep(1);
}
