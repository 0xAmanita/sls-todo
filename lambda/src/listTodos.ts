import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { QueryCommand } from '@aws-sdk/lib-dynamodb';
import { docClient, TABLE, getUserId, response } from './utils';

export async function handler(event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> {
  try {
    const userId = getUserId(event);
    if (!userId) {
      return response(401, { error: 'Unauthorized' });
    }

    const { Items } = await docClient.send(new QueryCommand({
      TableName: TABLE,
      IndexName: 'UserIdIndex',
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      }
    }));

    return response(200, Items || []);
  } catch (err) {
    console.error('Error listing todos:', err);
    const message = err instanceof Error ? err.message : 'Internal Server Error';
    return response(500, { error: message });
  }
}
