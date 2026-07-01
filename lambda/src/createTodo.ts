import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { PutCommand } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'crypto';
import { docClient, TABLE, getUserId, response } from './utils';

export async function handler(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  try {
    const userId = getUserId(event);
    if (!userId) {
      return response(401, { error: 'Unauthorized' });
    }

    const { title, description } = JSON.parse(event.body || '{}');
    
    if (!title) {
      return response(400, { error: 'Title is required' });
    }

    const id = randomUUID();
    const createdAt = new Date().toISOString();

    await docClient.send(new PutCommand({
      TableName: TABLE,
      Item: { id, userId, title, description, createdAt },
    }));

    return response(201, { id, title, description, createdAt });
  } catch (err) {
    console.error('Error creating todo:', err);
    const message = err instanceof Error ? err.message : 'Internal Server Error';
    return response(500, { error: message });
  }
}
