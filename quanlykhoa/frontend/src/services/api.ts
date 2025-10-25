// frontend/src/services/api.ts
export const API_BASE = import.meta.env.VITE_API_BASE || "http://localhost:8080";

export type LoginResponse = {
  token: string;
  user: { id: string; email: string; hoTen: string; vaiTro: string };
};

async function fetchJson<T>(url: string, init?: RequestInit): Promise<T> {
  const token = localStorage.getItem("token");
  const res = await fetch(url, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...(init?.headers || {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error((err as any).error || `HTTP ${res.status}`);
  }
  return res.json();
}

/** AUTH */
export function apiLogin(email: string, password: string) {
  return fetchJson<LoginResponse>(`${API_BASE}/api/auth/login`, {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
}

export function apiRegister(hoTen: string, email: string, password: string) {
  return fetchJson<LoginResponse>(`${API_BASE}/api/auth/register`, {
    method: "POST",
    body: JSON.stringify({ hoTen, email, password }),
  });
}
