import { Request, Response, NextFunction } from 'express';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, ScanCommand, GetCommand, UpdateCommand, DeleteCommand } from '@aws-sdk/lib-dynamodb';
import { randomUUID } from 'crypto';

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.TABLE_NAME || 'todos';

export const createTodo = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description } = req.body;
    const id = randomUUID();
    
    await docClient.send(new PutCommand({
      TableName: TABLE_NAME,
      Item: { id, title, description, createdAt: new Date().toISOString() }
    }));
    
    res.status(201).json({ id, title, description });
  } catch (error) {
    next(error);
  }
};

export const listTodos = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await docClient.send(new ScanCommand({
      TableName: TABLE_NAME
    }));
    
    res.json(result.Items || []);
  } catch (error) {
    next(error);
  }
};

export const getTodo = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    
    const result = await docClient.send(new GetCommand({
      TableName: TABLE_NAME,
      Key: { id }
    }));
    
    if (!result.Item) {
      return res.status(404).json({ error: 'Todo not found' });
    }
    
    res.json(result.Item);
  } catch (error) {
    next(error);
  }
};

export const updateTodo = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { title, description } = req.body;
    
    await docClient.send(new UpdateCommand({
      TableName: TABLE_NAME,
      Key: { id },
      UpdateExpression: 'SET title = :title, description = :description, updatedAt = :updatedAt',
      ExpressionAttributeValues: {
        ':title': title,
        ':description': description,
        ':updatedAt': new Date().toISOString()
      }
    }));
    
    res.json({ id, title, description });
  } catch (error) {
    next(error);
  }
};

export const deleteTodo = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    
    await docClient.send(new DeleteCommand({
      TableName: TABLE_NAME,
      Key: { id }
    }));
    
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
