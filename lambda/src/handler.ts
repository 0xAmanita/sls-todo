import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { createTodo, listTodos, getTodo, updateTodo, deleteTodo } from './todos';

function getUserId(event: APIGatewayProxyEvent): string | null {
  // API Gateway HTTP API v2 stores JWT claims in requestContext.authorizer.jwt.claims
  // The authorizer property might need type assertion due to TypeScript definitions
  const requestContext = event.requestContext as any;
  const claims = requestContext?.authorizer?.jwt?.claims;
  
  if (!claims) {
    console.log('No JWT claims found in request context');
    return null;
  }
  
  // The 'sub' claim contains the Cognito user ID
  const sub = claims.sub;
  console.log('Extracted userId (sub):', sub);
  
  return sub ? String(sub) : null;
}

export async function handler(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  const { httpMethod: method, path } = event;
  const id = event.pathParameters?.id;
  
  // Log everything for debugging
  console.log('=== REQUEST DEBUG ===');
  console.log('Path:', path);
  console.log('Method:', method);
  console.log('Headers:', JSON.stringify(event.headers, null, 2));
  console.log('RequestContext:', JSON.stringify(event.requestContext, null, 2));
  console.log('===================');
  
  const userId = getUserId(event);

  try {
    // root path - API info
    if (method === 'GET' && path === '/') {
      return {
        statusCode: 200,
        body: JSON.stringify({
          message: 'Todo API',
          version: '1.0.0',
          endpoints: {
            'GET /todos': 'List all todos',
            'POST /todos': 'Create a new todo',
            'GET /todos/{id}': 'Get a specific todo',
            'PUT /todos/{id}': 'Update a todo',
            'DELETE /todos/{id}': 'Delete a todo',
          },
        }),
      };
    }

    // check userId
    if(!userId) {
      return {
        statusCode: 401,
        body: JSON.stringify({error: 'Unauthorized'})
      };
    }

    if (method === 'POST'   && path === '/todos')        return await createTodo(event, userId);
    if (method === 'GET'    && path === '/todos')        return await listTodos(userId);
    if (method === 'GET'    && path.startsWith('/todos/')) return await getTodo(id!, userId);
    if (method === 'PUT'    && path.startsWith('/todos/')) return await updateTodo(id!, event, userId);
    if (method === 'DELETE' && path.startsWith('/todos/')) return await deleteTodo(id!, userId);

    return { statusCode: 404, body: JSON.stringify({ error: 'Not found' }) };
  } catch (err) {
    console.error(err);
    const message = err instanceof Error ? err.message : 'Internal Server Error';
    return { statusCode: 500, body: JSON.stringify({ error: message }) };
  }
}
