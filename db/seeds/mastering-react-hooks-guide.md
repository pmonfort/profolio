---
title: "Mastering React Hooks: A Comprehensive Guide"
date: "2024-02-25"
excerpt: "Dive deep into React Hooks and learn how to write modern, efficient React components. From useState to custom hooks, we cover it all."
category: "tutorial"
---

React Hooks revolutionized how we write React components. Introduced in React 16.8, hooks allow us to use state and other React features in functional components. This guide will take you from hooks basics to advanced patterns.

## What Are Hooks?

Hooks are functions that let you "hook into" React features like state and lifecycle methods from functional components. They solve several problems:

- Reusing stateful logic between components
- Breaking down complex components
- Easier to understand than class components

## useState: Managing Component State

The `useState` hook is the most fundamental hook:

```typescript
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}
```

### Functional Updates

When the new state depends on the previous state, use the functional form:

```typescript
function Counter() {
  const [count, setCount] = useState(0);
  
  const increment = () => {
    setCount(prevCount => prevCount + 1);
  };
  
  const incrementBy = (amount: number) => {
    setCount(prevCount => prevCount + amount);
  };
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>+1</button>
      <button onClick={() => incrementBy(5)}>+5</button>
    </div>
  );
}
```

### Complex State

For multiple related state values, you can use an object:

```typescript
function UserForm() {
  const [user, setUser] = useState({
    name: '',
    email: '',
    age: 0,
  });
  
  const updateField = (field: string, value: string | number) => {
    setUser(prev => ({
      ...prev,
      [field]: value,
    }));
  };
  
  return (
    <form>
      <input
        value={user.name}
        onChange={(e) => updateField('name', e.target.value)}
        placeholder="Name"
      />
      <input
        value={user.email}
        onChange={(e) => updateField('email', e.target.value)}
        placeholder="Email"
      />
      <input
        type="number"
        value={user.age}
        onChange={(e) => updateField('age', parseInt(e.target.value))}
        placeholder="Age"
      />
    </form>
  );
}
```

## useEffect: Side Effects

`useEffect` handles side effects like API calls, subscriptions, and DOM manipulation:

```typescript
import { useState, useEffect } from 'react';

function UserProfile({ userId }: { userId: number }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    async function fetchUser() {
      setLoading(true);
      const response = await fetch(`/api/users/${userId}`);
      const data = await response.json();
      setUser(data);
      setLoading(false);
    }
    
    fetchUser();
  }, [userId]); // Only re-run if userId changes
  
  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;
  
  return <div>{user.name}</div>;
}
```

### Cleanup

Some effects need cleanup:

```typescript
function Timer() {
  const [seconds, setSeconds] = useState(0);
  
  useEffect(() => {
    const interval = setInterval(() => {
      setSeconds(prev => prev + 1);
    }, 1000);
    
    // Cleanup function
    return () => clearInterval(interval);
  }, []); // Empty array means this effect runs once on mount
  
  return <div>Seconds: {seconds}</div>;
}
```

## useContext: Sharing Data

`useContext` lets you consume context values:

```typescript
import { createContext, useContext, useState, ReactNode } from 'react';

// Create context
const ThemeContext = createContext<{
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}>({
  theme: 'light',
  toggleTheme: () => {},
});

// Provider component
function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  
  const toggleTheme = () => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  };
  
  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// Consumer component
function ThemedButton() {
  const { theme, toggleTheme } = useContext(ThemeContext);
  
  return (
    <button
      onClick={toggleTheme}
      style={{
        backgroundColor: theme === 'light' ? '#fff' : '#000',
        color: theme === 'light' ? '#000' : '#fff',
      }}
    >
      Current theme: {theme}
    </button>
  );
}
```

## useReducer: Complex State Logic

For complex state logic, `useReducer` is more powerful than `useState`:

```typescript
import { useReducer } from 'react';

type State = {
  count: number;
  step: number;
};

type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'reset' }
  | { type: 'setStep'; step: number };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + state.step };
    case 'decrement':
      return { ...state, count: state.count - state.step };
    case 'reset':
      return { ...state, count: 0 };
    case 'setStep':
      return { ...state, step: action.step };
    default:
      return state;
  }
}

function Counter() {
  const [state, dispatch] = useReducer(reducer, { count: 0, step: 1 });
  
  return (
    <div>
      <p>Count: {state.count}</p>
      <input
        type="number"
        value={state.step}
        onChange={(e) => dispatch({ type: 'setStep', step: parseInt(e.target.value) })}
      />
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      <button onClick={() => dispatch({ type: 'reset' })}>Reset</button>
    </div>
  );
}
```

## useMemo and useCallback: Performance Optimization

### useMemo

Memoize expensive calculations:

```typescript
import { useMemo, useState } from 'react';

function ExpensiveComponent({ items }: { items: number[] }) {
  const [filter, setFilter] = useState('');
  
  // This expensive calculation only runs when items or filter changes
  const filteredItems = useMemo(() => {
    console.log('Filtering items...');
    return items.filter(item => item.toString().includes(filter));
  }, [items, filter]);
  
  return (
    <div>
      <input
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        placeholder="Filter"
      />
      <ul>
        {filteredItems.map(item => (
          <li key={item}>{item}</li>
        ))}
      </ul>
    </div>
  );
}
```

### useCallback

Memoize callback functions:

```typescript
import { useState, useCallback, memo } from 'react';

const ExpensiveChild = memo(({ onClick, name }: { onClick: () => void; name: string }) => {
  console.log(`Rendering ${name}`);
  return <button onClick={onClick}>{name}</button>;
});

function Parent() {
  const [count, setCount] = useState(0);
  const [name, setName] = useState('');
  
  // This function reference stays the same unless dependencies change
  const handleClick = useCallback(() => {
    console.log('Button clicked');
  }, []); // Empty array means function never changes
  
  return (
    <div>
      <input value={name} onChange={(e) => setName(e.target.value)} />
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
      <ExpensiveChild onClick={handleClick} name={name} />
    </div>
  );
}
```

## Custom Hooks

Extract and reuse stateful logic:

```typescript
// Custom hook: useLocalStorage
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      return initialValue;
    }
  });
  
  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  };
  
  return [storedValue, setValue] as const;
}

// Usage
function Settings() {
  const [theme, setTheme] = useLocalStorage('theme', 'light');
  
  return (
    <div>
      <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
        Theme: {theme}
      </button>
    </div>
  );
}
```

## Rules of Hooks

1. **Only call hooks at the top level**: Don't call hooks inside loops, conditions, or nested functions
2. **Only call hooks from React functions**: Call hooks from React functional components or custom hooks

```typescript
// ❌ Wrong
function Component() {
  if (condition) {
    const [state, setState] = useState(0); // Don't do this!
  }
}

// ✅ Correct
function Component() {
  const [state, setState] = useState(0); // Always at the top level
  
  if (condition) {
    // Use state here
  }
}
```

## Conclusion

React Hooks provide a powerful, flexible way to write React components. They make code more reusable, easier to test, and simpler to understand. Master these hooks, and you'll be building better React applications in no time.

Remember:
- Start with `useState` and `useEffect`
- Use `useMemo` and `useCallback` for optimization (but don't overuse)
- Create custom hooks to share logic
- Always follow the Rules of Hooks

Happy hooking!

