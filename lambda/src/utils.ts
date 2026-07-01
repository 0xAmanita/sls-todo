import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

export const docClient = DynamoDBDocumentClient.from(new DynamoDBClient({}));
export const TABLE = process.env.TABLE_NAME || 'todos';

export function getUserId(event: APIGatewayProxyEvent): string | null {
  const requestContext = event.requestContext as any;
  const claims = requestContext?.authorizer?.claims;
  
  if (!claims) {
    return null;
  }
  
  const sub = claims.sub;
  return sub ? String(sub) : null;
}

export function response(statusCode: number, body: unknown): APIGatewayProxyResult {
  return {
    statusCode,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  };
}
