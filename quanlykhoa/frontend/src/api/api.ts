import axios from 'axios';
const base = import.meta.env.VITE_API_BASE || ''; // dev dùng http://localhost:8080, prod dùng cùng domain
const api = axios.create({ baseURL: base });
api.interceptors.request.use(cfg => {
  const token = localStorage.getItem('accessToken');
  if (token) cfg.headers.Authorization = `Bearer ${token}`;
  return cfg;
});
export default api;
