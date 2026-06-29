import express from 'express';
import serverless from 'serverless-http';
import todoRoutes from './routes/todo.routes';
import { errorHandler } from './middleware/errorHandler';

const app = express();

app.use(express.json());
app.use('/', todoRoutes);
app.use(errorHandler);

export const handler = serverless(app);

if (process.env.NODE_ENV === 'development') {
  const PORT = 3000;
  app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}
