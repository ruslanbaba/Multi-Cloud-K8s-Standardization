import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { configureRoutes } from './routes';
import { errorHandler } from './middleware/errorHandler';
import { setupK8sClients } from './services/k8s';
import { logger } from './utils/logger';

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Initialize K8s clients
setupK8sClients().catch(err => {
  logger.error('Failed to initialize K8s clients:', err);
  process.exit(1);
});

// Configure routes
configureRoutes(app);

// Error handling
app.use(errorHandler);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});
