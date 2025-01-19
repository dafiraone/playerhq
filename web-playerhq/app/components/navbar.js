import Link from 'next/link';
import React from 'react';

const Navbar = ({role}) => {
  return (
    <nav className="bg-blue-600 p-4 text-white">
      <div className="container mx-auto flex justify-between items-center">
        <div className="text-lg font-bold">{role} Dashboard</div>
        <ul className="flex space-x-6">
          {role === "Admin" ? <>
            <li><Link href="/admin/transaction" className="hover:text-blue-300">Transaction</Link></li>
            <li><Link href="/users" className="hover:text-blue-300">Users</Link></li>
          </>
          : null
          }
          <li><Link href="/" className="hover:text-blue-300">Settings</Link></li>
          <li><Link href="/login" className="hover:text-blue-300">Logout</Link></li>
        </ul>
      </div>
    </nav>
  );
}

export default Navbar;
