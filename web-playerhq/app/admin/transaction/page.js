"use client"

import { useEffect, useState } from 'react'
import Link from 'next/link'
import Navbar from '../../components/navbar'

export default function Transactions() {
  const [transactions, setTransactions] = useState([])
  const [users, setUsers] = useState([])

  // Fetch transactions from API
  useEffect(() => {
    const fetchTransactions = async () => {
      const transaction = await fetch('/api/transaction')
      const transactionJson = await transaction.json()
      setTransactions(transactionJson)

      const user = await fetch("/api/users")
      const userJson = await user.json()
      setUsers(userJson)
    }
    fetchTransactions()
  }, [])

  const getUserName = (userId) => {
    const user = users.find(user => user.user_id === userId)
    return user ? user.username : 'Anonymous'
  }

  return (
    <>
    <Navbar role="Admin" />
    <div className="container mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Transaction List</h1>
      <table className="min-w-full table-auto border-collapse">
        <thead>
          <tr>
            <th className="px-4 py-2 border-b">Transaction ID</th>
            <th className="px-4 py-2 border-b">Username</th>
            <th className="px-4 py-2 border-b">Amount</th>
            <th className="px-4 py-2 border-b">Status</th>
            <th className="px-4 py-2 border-b">Actions</th>
          </tr>
        </thead>
        <tbody>
          {transactions.map((transaction) => (
            <tr key={transaction.transaction_id}>
              <td className="px-4 py-2 border-b text-center">{transaction.transaction_id}</td>
              <td className="px-4 py-2 border-b text-center">{getUserName(transaction.user_id)}</td>
              <td className="px-4 py-2 border-b text-center">{new Intl.NumberFormat('id-ID', {
  style: 'currency',
  currency: 'IDR',
  minimumFractionDigits: 0
}).format(transaction.amount)}</td>
              <td className="px-4 py-2 border-b text-center">{transaction.status}</td>
              <td className="px-4 py-2 border-b text-center">
                <Link href={`/transaction/${transaction.transaction_id}`} className="text-blue-500 hover:underline">
                  View
                </Link>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
    </>
  )
}
