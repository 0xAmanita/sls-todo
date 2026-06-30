import { useState, type FormEvent } from 'react';
import { signIn } from 'aws-amplify/auth';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');

    try {
      await signIn({
        username: email,
        password,
      });
      navigate('/todos');
    } catch (err: any) {
      setError(err.message || 'Login failed');
    }
  };

  return (
    <div className="container">
      <div className="card">
        <h2>Whut To Do</h2>
        <form onSubmit={handleSubmit}>
          <div className="mb-md">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              placeholder="Enter your email"
            />
          </div>
          <div className="mb-md">
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              placeholder="Enter your password"
            />
          </div>
          {error && <div className="message message-error">{error}</div>}
          <button type="submit" style={{ width: '100%' }}>
            Sign In
          </button>
        </form>
        <p className="text-center mt-md" style={{ marginBottom: 0 }}>
          Don't have an account? <a href="/register">Create one</a>
        </p>
      </div>
    </div>
  );
}
