"use client"

import { useEffect, useState } from 'react'
import { useRouter, usePathname } from "next/navigation"

export default function TransactionDetail({params}) {
  const [transaction, setTransaction] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const router = useRouter()
  
  const id = usePathname().split("/").slice(-1)[0] // get ID

  useEffect(() => {
    if (id) {
      const fetchTransaction = async () => {
        try {
          const res = await fetch(`/api/transaction/${id}`)
          const data = await res.json()
          if (res.ok) {
            setTransaction(data)
          } else {
            setError(data.message)
          }
        } catch (err) {
          setError('Failed to fetch transaction data')
        } finally {
          setLoading(false)
        }
      }
      fetchTransaction()
    }
  }, [id])

  if (loading) return <div className="container mx-auto p-6">Loading...</div>
  if (error) return <div className="container mx-auto p-6 text-red-500">{error}</div>

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Transaction Details</h1>
      <div className="space-y-4">
        <p><strong>Transaction ID:</strong> {transaction.transaction_id}</p>
        <p><strong>User ID:</strong> {transaction.user_id}</p>
        <p><strong>Amount:</strong> {transaction.amount}</p>
        <p><strong>Status:</strong> {transaction.status}</p>
        <p><strong>Game API ID:</strong> {transaction.game_api_id}</p>
        <p><strong>Transaction Date:</strong> {transaction.transaction_date}</p>
      </div>
    </div>
  )
}
