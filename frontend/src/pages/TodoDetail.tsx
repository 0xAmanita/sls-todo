import { useEffect, useState, type FormEvent } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import client from '../api/client';

interface Todo {
  id: string;
  title: string;
  description: string;
  createdAt?: string;
}

export default function TodoDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [todo, setTodo] = useState<Todo | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [editing, setEditing] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');

  useEffect(() => {
    fetchTodo();
  }, [id]);

  const fetchTodo = async () => {
    try {
      const response = await client.get(`/todos/${id}`);
      setTodo(response.data);
      setTitle(response.data.title);
      setDescription(response.data.description);
      setLoading(false);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch todo');
      setLoading(false);
    }
  };

  const handleUpdate = async (e: FormEvent) => {
    e.preventDefault();
    setError('');

    try {
      await client.put(`/todos/${id}`, { title, description });
      setTodo({ ...todo!, title, description });
      setEditing(false);
    } catch (err: any) {
      setError(err.message || 'Failed to update todo');
    }
  };

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this todo?')) return;

    try {
      await client.delete(`/todos/${id}`);
      navigate('/todos');
    } catch (err: any) {
      setError(err.message || 'Failed to delete todo');
    }
  };

  if (loading) return <div className="loading">Loading...</div>;
  if (error && !todo) return <div className="loading" style={{ color: 'var(--danger)' }}>{error}</div>;
  if (!todo) return <div className="loading">Todo not found</div>;

  return (
    <div className="container container-lg">
      <div className="card">
        <button 
          onClick={() => navigate('/todos')} 
          className="btn-secondary btn-small"
          style={{ marginBottom: 'var(--spacing-lg)', alignSelf: 'flex-start' }}
        >
          ← Back to List
        </button>

        {editing ? (
          <form onSubmit={handleUpdate}>
            <div className="mb-md">
              <label>Title</label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                required
              />
            </div>
            <div className="mb-md">
              <label>Description</label>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                required
              />
            </div>
            {error && <div className="message message-error">{error}</div>}
            <div className="flex gap-sm">
              <button type="submit" className="btn-primary" style={{ flex: 1 }}>
                Save Changes
              </button>
              <button 
                type="button" 
                onClick={() => setEditing(false)}
                className="btn-secondary"
                style={{ flex: 1 }}
              >
                Cancel
              </button>
            </div>
          </form>
        ) : (
          <>
            <h2 style={{ textAlign: 'left' }}>{todo.title}</h2>
            <p style={{ 
              whiteSpace: 'pre-wrap', 
              marginBottom: 'var(--spacing-lg)',
              textAlign: 'left',
              color: 'var(--text-secondary)'
            }}>
              {todo.description}
            </p>
            {todo.createdAt && (
              <p style={{ 
                color: 'var(--text-muted)', 
                fontSize: '0.875rem',
                marginBottom: 'var(--spacing-lg)',
                textAlign: 'left'
              }}>
                Created: {new Date(todo.createdAt).toLocaleString()}
              </p>
            )}
            <div className="flex gap-sm">
              <button 
                onClick={() => setEditing(true)}
                className="btn-primary"
                style={{ flex: 1 }}
              >
                Edit
              </button>
              <button 
                onClick={handleDelete}
                className="btn-danger"
                style={{ flex: 1 }}
              >
                Delete
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
