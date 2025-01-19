import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';

export default function TransactionForm() {
  const router = useRouter();
  const { id } = router.query; // Transaction ID from URL for Update
  const [transaction, setTransaction] = useState({
    game_api_id: '',
    amount: '',
    user_id: '',
    status: '',
  });
  const [loading, setLoading] = useState(false);

  // Fetch transaction data if editing
  useEffect(() => {
    if (id) {
      const fetchTransaction = async () => {
        const res = await fetch(`/api/transaction/${id}`);
        const data = await res.json();
        setTransaction(data);
      };
      fetchTransaction();
    }
  }, [id]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    const method = id ? 'PUT' : 'POST';
    const url = id ? `/api/transaction/${id}` : '/api/transaction';

    try {
      const res = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(transaction),
      });

      if (res.ok) {
        router.push('/transactions');
      } else {
        console.error('Error submitting transaction');
      }
    } catch (error) {
      console.error('Error submitting transaction:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">{id ? 'Edit' : 'Add'} Transaction</h1>
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label htmlFor="game_api_id" className="block text-sm">Game API ID</label>
          <input
            type="text"
            id="game_api_id"
            value={transaction.game_api_id}
            onChange={(e) => setTransaction({ ...transaction, game_api_id: e.target.value })}
            className="w-full p-3 text-lg border border-gray-300 rounded-md"
            required
          />
        </div>

        <div>
          <label htmlFor="amount" className="block text-sm">Amount</label>
          <input
            type="number"
            id="amount"
            value={transaction.amount}
            onChange={(e) => setTransaction({ ...transaction, amount: e.target.value })}
            className="w-full p-3 text-lg border border-gray-300 rounded-md"
            required
          />
        </div>

        <div>
          <label htmlFor="user_id" className="block text-sm">User ID</label>
          <input
            type="text"
            id="user_id"
            value={transaction.user_id}
            onChange={(e) => setTransaction({ ...transaction, user_id: e.target.value })}
            className="w-full p-3 text-lg border border-gray-300 rounded-md"
            required
          />
        </div>

        <div>
          <label htmlFor="status" className="block text-sm">Status</label>
          <select
            id="status"
            value={transaction.status}
            onChange={(e) => setTransaction({ ...transaction, status: e.target.value })}
            className="w-full p-3 text-lg border border-gray-300 rounded-md"
            required
          >
            <option value="PENDING">PENDING</option>
            <option value="BERHASIL">BERHASIL</option>
            <option value="BATAL">BATAL</option>
          </select>
        </div>

        <button
          type="submit"
          disabled={loading}
          className={`w-full py-3 text-lg rounded-md ${loading ? 'bg-gray-300 cursor-not-allowed' : 'bg-blue-500 text-white hover:bg-blue-700'}`}
        >
          {loading ? 'Submitting...' : 'Submit'}
        </button>
      </form>
    </div>
  );
}
