import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './pages/Login';
import Register from './pages/Register';
import ConfirmEmail from './pages/ConfirmEmail';
import TodoList from './pages/TodoList';
import CreateTodo from './pages/CreateTodo';
import TodoDetail from './pages/TodoDetail';
import ProtectedRoute from './components/ProtectedRoute';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/login" />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/confirm-email" element={<ConfirmEmail />} />
        <Route 
          path="/todos" 
          element={
            <ProtectedRoute>
              <TodoList />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/todos/create" 
          element={
            <ProtectedRoute>
              <CreateTodo />
            </ProtectedRoute>
          } 
        />
        <Route 
          path="/todos/:id" 
          element={
            <ProtectedRoute>
              <TodoDetail />
            </ProtectedRoute>
          } 
        />
      </Routes>
    </Router>
  );
}

export default App
