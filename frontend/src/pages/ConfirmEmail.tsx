import { useState, type FormEvent } from 'react';
import { confirmSignUp, resendSignUpCode } from 'aws-amplify/auth';
import { useNavigate, useLocation } from 'react-router-dom';

export default function ConfirmEmail() {
  const navigate = useNavigate();
  const location = useLocation();
  const emailFromState = location.state?.email || '';

  const [email, setEmail] = useState(emailFromState);
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    setMessage('');
    setLoading(true);

    try {
      await confirmSignUp({
        username: email,
        confirmationCode: code,
      });
      setMessage('Email confirmed successfully! Redirecting to login...');
      setTimeout(() => navigate('/login'), 2000);
    } catch (err: any) {
      setError(err.message || 'Verification failed');
    } finally {
      setLoading(false);
    }
  };

  const handleResendCode = async () => {
    setError('');
    setMessage('');
    setLoading(true);

    try {
      await resendSignUpCode({ username: email });
      setMessage('Verification code sent! Check your email.');
    } catch (err: any) {
      setError(err.message || 'Failed to resend code');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container">
      <div className="card">
        <h2>Confirm Your Email</h2>
        <p style={{ marginBottom: '1.5rem', color: '#666' }}>
          We've sent a verification code to your email. Please enter it below to confirm your account.
        </p>
        
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
            <label>Verification Code</label>
            <input
              type="text"
              value={code}
              onChange={(e) => setCode(e.target.value)}
              required
              placeholder="Enter 6-digit code"
              maxLength={6}
            />
          </div>

          {error && <div className="message message-error">{error}</div>}
          {message && <div className="message message-success">{message}</div>}

          <button 
            type="submit" 
            style={{ width: '100%' }}
            disabled={loading}
          >
            {loading ? 'Verifying...' : 'Confirm Email'}
          </button>
        </form>

        <div style={{ marginTop: '1rem', textAlign: 'center' }}>
          <button
            onClick={handleResendCode}
            disabled={loading || !email}
            style={{
              background: 'none',
              border: 'none',
              color: '#007bff',
              cursor: 'pointer',
              textDecoration: 'underline',
              padding: 0,
            }}
          >
            Resend verification code
          </button>
        </div>

        <p className="text-center mt-md" style={{ marginBottom: 0 }}>
          Already verified? <a href="/login">Sign in</a>
        </p>
      </div>
    </div>
  );
}
