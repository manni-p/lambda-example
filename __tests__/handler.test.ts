import { handler, LambdaEvent } from '../handler';
import { StatusCodes } from 'http-status-codes';
import { APIGatewayProxyEvent } from 'aws-lambda';
import { describe, expect, it, vi } from 'vitest';

global.console.log = vi.fn();

describe('Lambda Handler', () => {
  it('should return a successful response with the correct email', async () => {
    const mockEvent: Partial<APIGatewayProxyEvent> = {
      body: JSON.stringify({ email: 'test@test.com' }),
      headers: {},
      httpMethod: 'POST',
    };

    const result = await handler(mockEvent as LambdaEvent);

    expect(result.statusCode).toBe(StatusCodes.OK);
    const body = JSON.parse(result.body);
    expect(body.Payload.email).toBe('test@test.com');
  });

  it('should log the correct output', async () => {
    const mockEvent: Partial<APIGatewayProxyEvent> = {
      body: JSON.stringify({ email: 'test@test.com' }),
      headers: {},
      httpMethod: 'POST',
    };

    await handler(mockEvent as any);

    expect(console.log).toHaveBeenCalledWith(
      'Response:',
      JSON.stringify({
        Payload: {
          email: 'test@test.com',
        },
      })
    );
  });
});
