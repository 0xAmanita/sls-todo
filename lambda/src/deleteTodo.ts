import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { GetCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
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

    await docClient.send(new DeleteCommand({
      TableName: TABLE,
      Key: { id }
    }));

    return { statusCode: 204, body: '' };
  } catch (err) {
    console.error('Error deleting todo:', err);
    const message = err instanceof Error ? err.message : 'Internal Server Error';
    return response(500, { error: message });
  }
}
