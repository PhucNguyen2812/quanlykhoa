import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { apiListMyGroups, type Nhom } from "../services/api";

export default function HomePage() {
  const [groups, setGroups] = useState<Nhom[]>([]);
  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState("");

  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        setLoading(true);
        const data = await apiListMyGroups();
        if (mounted) setGroups(data || []);
      } catch (e: any) {
        if (mounted) setErr(e.message || "Không tải được danh sách nhóm");
      } finally {
        if (mounted) setLoading(false);
      }
    })();
    // nếu dialog tạo nhóm của bạn có phát event thì nghe để reload
    const onChanged = () => {
      setLoading(true);
      apiListMyGroups().then(setGroups).finally(() => setLoading(false));
    };
    window.addEventListener("groups:changed", onChanged);
    return () => {
      mounted = false;
      window.removeEventListener("groups:changed", onChanged);
    };
  }, []);

  return (
    <div className="rounded-xl bg-white p-6 shadow-sm">
      <h2 className="mb-4 text-2xl font-semibold">Màn hình chính</h2>

      {loading && <div>Đang tải…</div>}
      {err && <div className="text-red-600">{err}</div>}

      {!loading && !err && groups.length === 0 && (
        <div>Chưa có nhóm nào. Hãy bấm nút ở góc phải để tạo nhóm.</div>
      )}

      {!loading && groups.length > 0 && (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {groups.map((g) => {
            const name = g.tenNhom || g.tenNhom || "(Không tên)";
            const code = g.maNhom || g.maNhom || "";
            return (
              <Link
                key={g.id}
                to={`/nhom/${g.id}`}
                className="block rounded-xl border border-gray-200 p-4 hover:shadow-md"
              >
                <div className="text-lg font-semibold">{name}</div>
                {code && <div className="text-sm text-gray-500 mt-1">Mã nhóm: {code}</div>}
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
