// frontend/src/components/dialogs/AddGroupDialog.tsx
import React, { useState } from "react";
import { apiCreateGroup } from "../../services/api";

type Props = {
  open: boolean;
  onClose: () => void;
  refresh?: () => void; // gọi lại list sau khi tạo thành công
};

export default function AddGroupDialog({ open, onClose, refresh }: Props) {
  const [tenNhom, setTenNhom] = useState("");
  const [moTa, setMoTa] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [errMsg, setErrMsg] = useState("");

  if (!open) return null;

  const handleSubmit = async (e?: React.FormEvent) => {
    e?.preventDefault();
    if (!tenNhom.trim()) {
      setErrMsg("Tên nhóm là bắt buộc");
      return;
    }
    setSubmitting(true);
    setErrMsg("");
    try {
      await apiCreateGroup({
        tenNhom: tenNhom.trim(),      
        moTa: moTa.trim() || undefined,
      });
      setTenNhom("");
      setMoTa("");
      onClose();
      refresh?.();
    } catch (err: any) {
      setErrMsg(err?.message || "Internal Server Error");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-full max-w-lg rounded-xl bg-white p-6 shadow-lg">
        <div className="mb-4 flex items-center justify-between">
          <h3 className="text-xl font-semibold">Thêm nhóm</h3>
          <button
            onClick={onClose}
            className="rounded-full p-1.5 hover:bg-gray-100"
            aria-label="Close"
          >
            ✕
          </button>
        </div>

        {errMsg && (
          <div className="mb-3 rounded-md bg-red-50 px-3 py-2 text-sm text-red-700">
            {errMsg}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="mb-1 block text-sm font-medium">Tên nhóm *</label>
            <input
              className="w-full rounded-lg border border-gray-300 px-3 py-2 outline-none focus:border-blue-500"
              placeholder="Nhập tên nhóm"
              value={tenNhom}
              onChange={(e) => setTenNhom(e.target.value)}
            />
          </div>

          <div>
            <label className="mb-1 block text-sm font-medium">Mô tả</label>
            <textarea
              className="h-28 w-full rounded-lg border border-gray-300 px-3 py-2 outline-none focus:border-blue-500"
              placeholder="Nhập mô tả (không bắt buộc)"
              value={moTa}
              onChange={(e) => setMoTa(e.target.value)}
            />
          </div>

          <div className="mt-6 flex justify-end gap-3">
            <button
              type="button"
              className="rounded-lg border border-gray-300 px-4 py-2 text-gray-700 hover:bg-gray-50"
              onClick={onClose}
              disabled={submitting}
            >
              Hủy
            </button>
            <button
              type="submit"
              className="rounded-lg bg-blue-600 px-4 py-2 font-medium text-white hover:bg-blue-700 disabled:opacity-60"
              disabled={submitting}
            >
              {submitting ? "Đang tạo…" : "Tạo nhóm"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
