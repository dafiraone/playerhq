"use client"

import React, { useState, useEffect } from 'react';
import Navbar from '../components/navbar';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from "recharts";

const AdminPage = () => {
    const [chartData, setChartData] = useState([]); // State to store chart data

    useEffect(() => {
        document.title = "Admin Transaction"
        const fetchTransactions = async () => {
            // Fetch transaction data
            const transactionResponse = await fetch('/api/transaction');
            const transactionJson = await transactionResponse.json();
            
            // Fetch game data
            const gameResponse = await fetch("/api/test");
            const gameJson = await gameResponse.json();
            const games = gameJson["results"]
            
            const gameMapping = {};
            games.map(game => {
                gameMapping[game.id] = game.name;
            });

            // Count purchases per game
            const purchaseCount = {};
            transactionJson.map(trans => {
                const gameName = gameMapping[trans.game_api_id]; // Match transaction game_id with game name
                if (gameName) {
                    purchaseCount[gameName] = (purchaseCount[gameName] || 0) + 1;
                }
            });

            
            // Format data for the chart
            const formattedData = Object.keys(purchaseCount).map(gameName => ({
                name: gameName,
                purchases: purchaseCount[gameName],
            }));

            console.log(formattedData)
            
            // Set the data to be used by the chart
            setChartData(formattedData);
        };

        fetchTransactions();
    }, [])
    
    return (
        <div>
            <Navbar role="Admin" />
            <main className="container mx-auto p-6">
                <h1 className="text-3xl font-bold mb-6">Transaction Analytics</h1>
                <div style={{ width: '100%', height: 400 }}>
                    <h2>Purchased Games Chart</h2>
                    <ResponsiveContainer width="100%" height="100%">
                        <BarChart width={730} height={250} data={chartData}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="name" />
                            <YAxis />
                            <Tooltip />
                            <Legend />
                            <Bar dataKey="purchases" fill="#8884d8" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>
            </main>
        </div>
    );
}

export default AdminPage;
