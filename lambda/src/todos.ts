import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, ScanCommand, GetCommand, UpdateCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'crypto';

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.TABLE_NAME || 'todos';

function ok(statusCode: number, body: unknown): APIGatewayProxyResult {
  return { statusCode, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) };
}

export async function createTodo(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  const { title, description } = JSON.parse(event.body || '{}');
  const id = randomUUID();
  await docClient.send(new PutCommand({
    TableName: TABLE,
    Item: { id, title, description, createdAt: new Date().toISOString() },
  }));
  return ok(201, { id, title, description });
}

export async function listTodos(): Promise<APIGatewayProxyResult> {
  const { Items } = await docClient.send(new ScanCommand({ TableName: TABLE }));
  return ok(200, Items || []);
}

export async function getTodo(id: string): Promise<APIGatewayProxyResult> {
  const { Item } = await docClient.send(new GetCommand({ TableName: TABLE, Key: { id } }));
  return Item ? ok(200, Item) : ok(404, { error: 'Todo not found' });
}

export async function updateTodo(id: string, event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  const { title, description } = JSON.parse(event.body || '{}');
  await docClient.send(new UpdateCommand({
    TableName: TABLE,
    Key: { id },
    UpdateExpression: 'SET title = :t, description = :d, updatedAt = :u',
    ExpressionAttributeValues: { ':t': title, ':d': description, ':u': new Date().toISOString() },
  }));
  return ok(200, { id, title, description });
}

export async function deleteTodo(id: string): Promise<APIGatewayProxyResult> {
  await docClient.send(new DeleteCommand({ TableName: TABLE, Key: { id } }));
  return { statusCode: 204, body: '' };
}
