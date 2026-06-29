import { Router } from 'express';
import { createTodo, listTodos, getTodo, updateTodo, deleteTodo } from '../controllers/todo.controller';

const router = Router();

router.post('/todos', createTodo);
router.get('/todos', listTodos);
router.get('/todos/:id', getTodo);
router.put('/todos/:id', updateTodo);
router.delete('/todos/:id', deleteTodo);

export default router;
