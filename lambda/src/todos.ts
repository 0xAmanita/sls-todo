import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, QueryCommand, GetCommand, UpdateCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'crypto';

const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.TABLE_NAME || 'todos';

function ok(statusCode: number, body: unknown): APIGatewayProxyResult {
  return { statusCode, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) };
}

// Create Entry
export async function createTodo(event: APIGatewayProxyEvent, userId: string): Promise<APIGatewayProxyResult> {
  const { title, description } = JSON.parse(event.body || '{}');
  const id = randomUUID();
  await docClient.send(new PutCommand({
    TableName: TABLE,
    Item: { id, userId, title, description, createdAt: new Date().toISOString() },
  }));
  return ok(201, { id, title, description });
}

// Get Entries
export async function listTodos(userId: string): Promise<APIGatewayProxyResult> {
  const { Items } = await docClient.send(new QueryCommand({
    TableName: TABLE,
    IndexName: 'UserIdIndex',
    KeyConditionExpression: 'userId = :userId',
    ExpressionAttributeValues: {
      ':userId': userId
    }
  }));
  return ok(200, Items || []);
}

// Get Specific Entry
export async function getTodo(id: string, userId: string): Promise<APIGatewayProxyResult> {
  const { Item } = await docClient.send(new GetCommand({ TableName: TABLE, Key: { id } }));

  if (!Item) {
    return ok(404, {error: 'Entry not found'});
  }

  // make user user only see their own entries
  if (Item.userId !== userId) {
    return ok(403, {error: 'Forbidden'});
  }
  return ok(200, Item);
}

// Update To Do Entry
export async function updateTodo(id: string, event: APIGatewayProxyEvent, userId: string): Promise<APIGatewayProxyResult> {
  const { title, description } = JSON.parse(event.body || '{}');
  
  // Check ownership
  const {Item} = await docClient.send(new GetCommand({
    TableName: TABLE,
    Key: { id }
  }));

  if ( !Item ) {
    return ok(404, {error: 'Entry not found!'});
  }
  if ( Item.userId !== userId ) {
    return ok(403, {error: 'Forbidden!'});
  }

  await docClient.send(new UpdateCommand({
    TableName: TABLE,
    Key: { id },
    UpdateExpression: 'SET title = :t, description = :d, updatedAt = :u',
    ExpressionAttributeValues: { ':t': title, ':d': description, ':u': new Date().toISOString() },
  }));
  return ok(200, { id, title, description });
}

// Delete Entry
export async function deleteTodo(id: string, userId: string): Promise<APIGatewayProxyResult> {
  // Check owership

  const {Item} = await docClient.send(new GetCommand({
    TableName: TABLE,
    Key: { id }
  }));

  if ( !Item ) {
    return ok(404, {error: 'Entry not found!'});
  }
  if ( Item.userId !== userId ) {
    return ok(403, {error: 'Forbidden!'});
  }

  await docClient.send(new DeleteCommand({ TableName: TABLE, Key: { id } }));
  return { statusCode: 204, body: '' };
}
