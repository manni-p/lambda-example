import { APIGatewayProxyResult } from 'aws-lambda';
import { StatusCodes } from 'http-status-codes';
import { z } from 'zod';

const eventSchema = z.object({
  body: z.object({
    email: z.string().email(),
  }),
});

export type LambdaEvent = {
  body: string;
};

export const handler = async (
  event: LambdaEvent
): Promise<APIGatewayProxyResult> => {
  const { body } = eventSchema.parse({
    body: JSON.parse(event.body),
  });

  console.log(
    'Response:',
    JSON.stringify({
      Payload: {
        email: body.email,
      },
    })
  );

  return {
    statusCode: StatusCodes.OK,
    body: JSON.stringify({
      Payload: {
        email: body.email,
      },
    }),
  };
};
