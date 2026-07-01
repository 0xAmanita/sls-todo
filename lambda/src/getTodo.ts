import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { GetCommand } from '@aws-sdk/lib-dynamodb';
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

    return response(200, Item);
  } catch (err) {
    console.error('Error getting todo:', err);
    const message = err instanceof Error ? err.message : 'Internal Server Error';
    return response(500, { error: message });
  }
}
