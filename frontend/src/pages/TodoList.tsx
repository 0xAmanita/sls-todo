import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { signOut } from 'aws-amplify/auth';
import { useNavigate } from 'react-router-dom';
import client from '../api/client';

interface Todo {
  id: string;
  title: string;
  description: string;
}

export default function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    try {
      const response = await client.get('/todos');
      setTodos(response.data);
      setLoading(false);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch todos');
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    try {
      await signOut();
      navigate('/login');
    } catch (err) {
      console.error('Error signing out:', err);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this todo?')) return;
    
    try {
      await client.delete(`/todos/${id}`);
      setTodos(todos.filter(todo => todo.id !== id));
    } catch (err: any) {
      alert('Failed to delete todo: ' + err.message);
    }
  };

  if (loading) return <div className="loading">Loading...</div>;

  return (
    <div className="container container-lg">
      <div className="card">
        <div className="flex justify-between items-center mb-lg">
          <h2 style={{ marginBottom: 0 }}>My Todos</h2>
          <button onClick={handleLogout} className="btn-secondary btn-small">
            Logout
          </button>
        </div>

        {error && <div className="message message-error">{error}</div>}

        <Link to="/todos/create">
          <button className="btn-primary mb-lg" style={{ width: '100%' }}>
            Create New Todo
          </button>
        </Link>

        {todos.length === 0 ? (
          <p className="text-center" style={{ color: 'var(--text-muted)', padding: 'var(--spacing-xl) 0' }}>
            No todos yet. Create your first one!
          </p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-sm)' }}>
            {todos.map((todo) => (
              <div 
                key={todo.id} 
                style={{ 
                  border: '1px solid var(--border-color)', 
                  borderRadius: 'var(--radius-md)',
                  padding: 'var(--spacing-md)',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  transition: 'all 0.2s ease',
                  background: 'var(--bg-primary)'
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.boxShadow = 'var(--shadow-md)';
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.boxShadow = 'none';
                }}
              >
                <Link 
                  to={`/todos/${todo.id}`} 
                  style={{ 
                    textDecoration: 'none', 
                    flex: 1,
                    textAlign: 'left'
                  }}
                >
                  <h3 style={{ marginBottom: 'var(--spacing-xs)' }}>{todo.title}</h3>
                  <p style={{ 
                    margin: 0, 
                    color: 'var(--text-secondary)',
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap'
                  }}>
                    {todo.description}
                  </p>
                </Link>
                <button 
                  onClick={() => handleDelete(todo.id)}
                  className="btn-danger btn-small"
                  style={{ marginLeft: 'var(--spacing-md)' }}
                >
                  Delete
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
