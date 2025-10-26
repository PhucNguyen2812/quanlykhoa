import { Outlet, Link } from "react-router-dom";
import { useState } from "react";
import UserMenu from "../components/UserMenu";
import Sidebar from "../components/Sidebar";
import AddGroupDialog from "../components/dialogs/AddGroupDialog";
import JoinGroupDialog from "../components/dialogs/JoinGroupDialog";

export default function AppFrame() {
  const [showAddGroup, setShowAddGroup] = useState(false);
  const [showJoinGroup, setShowJoinGroup] = useState(false);

  // cho UserMenu gọi
  (window as any).openAddGroup = () => setShowAddGroup(true);
  (window as any).openJoinGroup = () => setShowJoinGroup(true);

  return (
    <div className="min-h-screen bg-[#f7f9fc]">
      <header className="sticky top-0 z-10 bg-white border-b">
        <div className="max-w-6xl mx-auto h-14 px-4 flex items-center justify-between">
          <Link to="/" className="font-semibold text-lg">Nhóm</Link>
          <UserMenu />
        </div>
      </header>

      <div className="max-w-6xl mx-auto px-4 py-6 flex gap-6">
        <Sidebar />
        <main className="flex-1">
        <Outlet />
        </main>
      </div>

      {showAddGroup && (
        <AddGroupDialog open={showAddGroup} onClose={() => setShowAddGroup(false)} />
      )}
      {showJoinGroup && (
        <JoinGroupDialog onClose={() => setShowJoinGroup(false)} onJoined={() => setShowJoinGroup(false)} />
      )}
    </div>
  );
}
