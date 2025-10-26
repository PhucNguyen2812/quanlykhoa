
import { NavLink } from "react-router-dom";

const Item = ({ to, children }: { to: string; children: React.ReactNode }) => (
  <NavLink
    to={to}
    className={({ isActive }) =>
      `flex items-center gap-2 px-3 py-2 rounded-xl hover:bg-gray-100 ${isActive ? "bg-gray-100 font-medium" : ""}`
    }
  >
    {children}
  </NavLink>
);

export default function Sidebar(){
  return (
    <aside className="w-64 shrink-0 border-r bg-white hidden md:block">
      <div className="p-3">
        <Item to="/">Màn hình chính</Item>
        <div className="mt-2 space-y-1">
          <Item to="/feature/1">Chức năng 1</Item>
          <Item to="/feature/2">Chức năng 2</Item>
          <Item to="/feature/3">Chức năng 3</Item>
          <Item to="/feature/4">Chức năng 4</Item>
          <Item to="/feature/5">Chức năng 5</Item>
          <Item to="/feature/6">Chức năng 6</Item>
        </div>
      </div>
    </aside>
  );
}
