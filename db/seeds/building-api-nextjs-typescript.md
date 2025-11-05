---
title: "Building RESTful APIs with Next.js and TypeScript"
date: "2024-02-20"
excerpt: "Learn how to create powerful, type-safe APIs using Next.js API routes and TypeScript. A complete guide with practical examples."
category: "tutorial"
---

Next.js provides a powerful way to build APIs right alongside your frontend code. Combined with TypeScript, you can create type-safe, maintainable API routes that integrate seamlessly with your application.

## Why Next.js API Routes?

Next.js API routes let you build backend functionality without a separate server:

- **Co-location**: APIs live with your frontend code
- **Type safety**: Full TypeScript support
- **Automatic routing**: File-based API routing
- **Middleware support**: Easy to add authentication, CORS, etc.
- **Serverless ready**: Deploy as serverless functions

## Setting Up Your Project

Start with a Next.js TypeScript project:

```bash
npx create-next-app@latest my-api-app --typescript
cd my-api-app
```

## Your First API Route

Create your first API endpoint:

```typescript
// app/api/hello/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({ message: 'Hello from Next.js API!' });
}
```

Visit `http://localhost:3000/api/hello` to see it in action.

## HTTP Methods

Next.js API routes support all HTTP methods:

```typescript
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';

// GET /api/users
export async function GET() {
  const users = [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
  ];
  
  return NextResponse.json(users);
}

// POST /api/users
export async function POST(request: NextRequest) {
  const body = await request.json();
  
  // Validate input
  if (!body.name || !body.email) {
    return NextResponse.json(
      { error: 'Name and email are required' },
      { status: 400 }
    );
  }
  
  // Create user (in a real app, save to database)
  const newUser = {
    id: Date.now(),
    name: body.name,
    email: body.email,
  };
  
  return NextResponse.json(newUser, { status: 201 });
}
```

## Type-Safe API Routes

Let's create type-safe APIs with TypeScript interfaces:

```typescript
// types/user.ts
export interface User {
  id: number;
  name: string;
  email: string;
  createdAt?: Date;
}

export interface CreateUserRequest {
  name: string;
  email: string;
}

// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { User, CreateUserRequest } from '@/types/user';

export async function GET(): Promise<NextResponse<User[]>> {
  const users: User[] = [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
  ];
  
  return NextResponse.json(users);
}

export async function POST(
  request: NextRequest
): Promise<NextResponse<User | { error: string }>> {
  try {
    const body: CreateUserRequest = await request.json();
    
    if (!body.name || !body.email) {
      return NextResponse.json(
        { error: 'Name and email are required' },
        { status: 400 }
      );
    }
    
    const newUser: User = {
      id: Date.now(),
      name: body.name,
      email: body.email,
      createdAt: new Date(),
    };
    
    return NextResponse.json(newUser, { status: 201 });
  } catch (error) {
    return NextResponse.json(
      { error: 'Invalid JSON' },
      { status: 400 }
    );
  }
}
```

## Dynamic Routes

Handle dynamic segments in your URLs:

```typescript
// app/api/users/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';

interface RouteParams {
  params: {
    id: string;
  };
}

export async function GET(
  request: NextRequest,
  { params }: RouteParams
) {
  const userId = parseInt(params.id);
  
  if (isNaN(userId)) {
    return NextResponse.json(
      { error: 'Invalid user ID' },
      { status: 400 }
    );
  }
  
  // Fetch user from database
  const user = { id: userId, name: 'John Doe', email: 'john@example.com' };
  
  if (!user) {
    return NextResponse.json(
      { error: 'User not found' },
      { status: 404 }
    );
  }
  
  return NextResponse.json(user);
}

export async function PUT(
  request: NextRequest,
  { params }: RouteParams
) {
  const userId = parseInt(params.id);
  const body = await request.json();
  
  // Update user logic here
  
  return NextResponse.json({ id: userId, ...body });
}

export async function DELETE(
  request: NextRequest,
  { params }: RouteParams
) {
  const userId = parseInt(params.id);
  
  // Delete user logic here
  
  return NextResponse.json({ message: 'User deleted' }, { status: 204 });
}
```

## Error Handling

Create reusable error handling:

```typescript
// app/api/error-handler.ts
import { NextResponse } from 'next/server';

export class ApiError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export function handleApiError(error: unknown): NextResponse {
  if (error instanceof ApiError) {
    return NextResponse.json(
      { error: error.message },
      { status: error.statusCode }
    );
  }
  
  console.error('Unexpected error:', error);
  return NextResponse.json(
    { error: 'Internal server error' },
    { status: 500 }
  );
}

// Usage in route
export async function GET() {
  try {
    // Your logic here
    throw new ApiError(404, 'Resource not found');
  } catch (error) {
    return handleApiError(error);
  }
}
```

## Middleware and Authentication

Add authentication middleware:

```typescript
// app/api/protected/route.ts
import { NextRequest, NextResponse } from 'next/server';

function isAuthenticated(request: NextRequest): boolean {
  const token = request.headers.get('authorization');
  // Validate token here
  return token === 'Bearer valid-token';
}

export async function GET(request: NextRequest) {
  if (!isAuthenticated(request)) {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 401 }
    );
  }
  
  return NextResponse.json({ message: 'Protected data' });
}
```

## Database Integration

Connect to a database using Prisma:

```typescript
// app/api/posts/route.ts
import { PrismaClient } from '@prisma/client';
import { NextRequest, NextResponse } from 'next/server';

const prisma = new PrismaClient();

export async function GET() {
  const posts = await prisma.post.findMany({
    include: { author: true },
    orderBy: { createdAt: 'desc' },
  });
  
  return NextResponse.json(posts);
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  
  const post = await prisma.post.create({
    data: {
      title: body.title,
      content: body.content,
      authorId: body.authorId,
    },
  });
  
  return NextResponse.json(post, { status: 201 });
}
```

## Testing Your APIs

Test your API routes:

```typescript
// __tests__/api/users.test.ts
import { GET, POST } from '@/app/api/users/route';
import { NextRequest } from 'next/server';

describe('/api/users', () => {
  it('should return users', async () => {
    const response = await GET();
    const data = await response.json();
    
    expect(response.status).toBe(200);
    expect(Array.isArray(data)).toBe(true);
  });
  
  it('should create a user', async () => {
    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({
        name: 'Test User',
        email: 'test@example.com',
      }),
    });
    
    const response = await POST(request);
    const data = await response.json();
    
    expect(response.status).toBe(201);
    expect(data.name).toBe('Test User');
  });
});
```

## Best Practices

1. **Validate input**: Always validate request data
2. **Use TypeScript**: Leverage types for safety
3. **Handle errors**: Return appropriate error responses
4. **Use status codes**: Return correct HTTP status codes
5. **Rate limiting**: Add rate limiting for production
6. **CORS**: Configure CORS if needed
7. **Environment variables**: Use env vars for secrets

## Conclusion

Next.js API routes combined with TypeScript provide a powerful, type-safe way to build backend functionality. Whether you're building a simple API or a complex backend, Next.js has you covered.

The co-location of APIs with your frontend code makes development faster and deployment simpler. Start building your APIs today!
