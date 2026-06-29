import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { createTodo, listTodos, getTodo, updateTodo, deleteTodo } from './todos';

export async function handler(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  const { httpMethod: method, path } = event;
  const id = event.pathParameters?.id;

  try {
    if (method === 'POST'   && path === '/todos')        return await createTodo(event);
    if (method === 'GET'    && path === '/todos')        return await listTodos();
    if (method === 'GET'    && path.startsWith('/todos/')) return await getTodo(id!);
    if (method === 'PUT'    && path.startsWith('/todos/')) return await updateTodo(id!, event);
    if (method === 'DELETE' && path.startsWith('/todos/')) return await deleteTodo(id!);

    return { statusCode: 404, body: JSON.stringify({ error: 'Not found' }) };
  } catch (err) {
    console.error(err);
    const message = err instanceof Error ? err.message : 'Internal Server Error';
    return { statusCode: 500, body: JSON.stringify({ error: message }) };
  }
}
