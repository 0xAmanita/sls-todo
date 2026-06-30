import { useState, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import client from '../api/client';

export default function CreateTodo() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');

    try {
      await client.post('/todos', { title, description });
      navigate('/todos');
    } catch (err: any) {
      setError(err.message || 'Failed to create todo');
    }
  };

  return (
    <div className="container container-md">
      <div className="card">
        <h2>Create New Todo</h2>
        <form onSubmit={handleSubmit}>
          <div className="mb-md">
            <label>Title</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              placeholder="Enter todo title"
            />
          </div>
          <div className="mb-md">
            <label>Description</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              required
              placeholder="Enter todo description"
            />
          </div>
          {error && <div className="message message-error">{error}</div>}
          <div className="flex gap-sm">
            <button type="submit" className="btn-primary" style={{ flex: 1 }}>
              Create
            </button>
            <button 
              type="button" 
              onClick={() => navigate('/todos')}
              className="btn-secondary"
              style={{ flex: 1 }}
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
