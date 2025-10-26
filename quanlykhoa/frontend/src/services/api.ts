
// frontend/src/services/api.ts
export const API_BASE =
  import.meta.env.VITE_API_BASE || "http://localhost:8080";

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
    // cố gắng đọc JSON, nếu không được thì đọc text thuần
    const ct = res.headers.get("content-type") || "";
    let detail: any = {};
    try {
      detail = ct.includes("application/json") ? await res.json() : await res.text();
    } catch {
      detail = await res.text().catch(() => "");
    }
    const msg =
      (typeof detail === "string" && detail) ||
      (detail && (detail.message || detail.error)) ||
      `HTTP ${res.status}`;
    throw new Error(msg);
  }

  // ok
  const ct = res.headers.get("content-type") || "";
  return (ct.includes("application/json") ? res.json() : (await res.text())) as any;
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

/** NHÓM */
export function apiCreateGroup(body: { tenNhom: string; moTa?: string }) {
  return fetchJson<any>(`${API_BASE}/api/nhom`, {
    method: "POST",
    body: JSON.stringify(body),
  });
}

export function apiJoinByCode(code: string) {
  return fetchJson<void>(`${API_BASE}/api/ma-moi/redeem`, {
    method: "POST",
    body: JSON.stringify({ code }),
  });
}

/** THÔNG BÁO */
export type ThongBao = {
  id: string;
  tieuDe: string;
  noiDung?: string;
  hanNop?: string;
  createdAt: string;
  nguoiDangId: string;
  soTep: number;
};

export async function apiListAnnouncements(
  nhomId: string
): Promise<ThongBao[]> {
  return fetchJson<ThongBao[]>(`${API_BASE}/api/nhom/${nhomId}/thong-bao`);
}

export async function apiCreateAnnouncement(
  nhomId: string,
  payload: { tieuDe: string; noiDung?: string; hanNop?: string; files?: File[] }
) {
  const fd = new FormData();
  fd.append("tieuDe", payload.tieuDe);
  if (payload.noiDung) fd.append("noiDung", payload.noiDung);
  if (payload.hanNop) {
    const iso = new Date(payload.hanNop).toISOString();
    fd.append("hanNop", iso);
  }
  (payload.files || []).forEach((f) => fd.append("files", f));

  const token = localStorage.getItem("token");
  const res = await fetch(`${API_BASE}/api/nhom/${nhomId}/thong-bao`, {
    method: "POST",
    headers: { ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: fd,
  });
  if (!res.ok) throw new Error(await res.text());
  return res.json();
}

export type Nhom = {
  id: string;
  maNhom?: string; 
  tenNhom?: string;
  moTa?: string;
};

export function apiListMyGroups() {
  return fetchJson<Nhom[]>(`${API_BASE}/api/nhom`);
}