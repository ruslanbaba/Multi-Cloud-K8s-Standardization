import { Router } from 'express';
import { validate } from '../middleware/validation';
import { DeploymentController } from '../controllers/deploymentController';
import { ClusterController } from '../controllers/clusterController';
import { AuthController } from '../controllers/authController';

export const configureRoutes = (app: Router) => {
  // Auth routes
  app.post('/api/auth/login', AuthController.login);
  app.post('/api/auth/refresh', AuthController.refreshToken);

  // Cluster management
  app.get('/api/clusters', ClusterController.listClusters);
  app.get('/api/clusters/:clusterId', ClusterController.getClusterDetails);
  app.get('/api/clusters/:clusterId/metrics', ClusterController.getClusterMetrics);

  // Deployment management
  app.get('/api/deployments', DeploymentController.listDeployments);
  app.post('/api/deployments', validate.deployment, DeploymentController.createDeployment);
  app.get('/api/deployments/:deploymentId', DeploymentController.getDeployment);
  app.put('/api/deployments/:deploymentId', validate.deployment, DeploymentController.updateDeployment);
  app.delete('/api/deployments/:deploymentId', DeploymentController.deleteDeployment);

  // Application templates
  app.get('/api/templates', DeploymentController.listTemplates);
  app.post('/api/templates', validate.template, DeploymentController.createTemplate);

  // Monitoring
  app.get('/api/metrics/cluster/:clusterId', ClusterController.getClusterMetrics);
  app.get('/api/metrics/deployment/:deploymentId', DeploymentController.getDeploymentMetrics);

  // Health check
  app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));
};
