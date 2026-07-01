import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { GetCommand, UpdateCommand } from '@aws-sdk/lib-dynamodb';
import { docClient, TABLE, getUserId, response } from './utils';

export async function handler(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  try {
    const userId = getUserId(event);
    if (!userId) {
      return response(401, { error: 'Unauthorized' });
    }

    const id = event.pathParameters?.id;
    if (!id) {
      return response(400, { error: 'Todo ID is required' });
    }

    const { title, description } = JSON.parse(event.body || '{}');

    // Check ownership
    const { Item } = await docClient.send(new GetCommand({
      TableName: TABLE,
      Key: { id }
    }));

    if (!Item) {
      return response(404, { error: 'Todo not found' });
    }

    if (Item.userId !== userId) {
      return response(403, { error: 'Forbidden' });
    }

    const updatedAt = new Date().toISOString();

    await docClient.send(new UpdateCommand({
      TableName: TABLE,
      Key: { id },
      UpdateExpression: 'SET title = :t, description = :d, updatedAt = :u',
      ExpressionAttributeValues: {
        ':t': title,
        ':d': description,
        ':u': updatedAt
      },
    }));

    return response(200, { id, title, description, updatedAt });
  } catch (err) {
    console.error('Error updating todo:', err);
    const message = err instanceof Error ? err.message : 'Internal Server Error';
    return response(500, { error: message });
  }
}
