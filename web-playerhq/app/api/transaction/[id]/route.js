import prisma from '../../../../prismaers'
import {  NextResponse } from 'next/server'

export async function GET(req, {params}) {
    const { id } = await params

    try {
        const transaction = await prisma.transaction.findFirst({
            where: {
                transaction_id: parseInt(id)
            }
        })
    
        return NextResponse.json(transaction)
    } catch (error) {
        return NextResponse.json({message: "Transaction Not Found"}, {status: 404})  
    }
}

export async function PUT(req, res) {
    const { id } = await res.params

    const transactionJson = await req.json()

    if (transactionJson.status !== "PENDING" || transactionJson.status !== "BATAL", transactionJson.status !== "BERHASIL") return NextResponse.json({message: "Wrong Status"}, {status: 404})

    const currentTransaction = await prisma.transaction.findFirst({
        where: {
            transaction_id: parseInt(id)
        }
    })

    await prisma.transaction.update({
        where: {
            transaction_id: parseInt(id) 
        },
        data: {
            amount: transactionJson.amount || currentTransaction.amount,
            game_api_id: transactionJson.game_api_id || currentTransaction.game_api_id,
            status: transactionJson.status || currentTransaction.status,
            transaction_date: transactionJson.transaction_date || currentTransaction.transaction_date,
            user_id: transactionJson.user_id || currentTransaction.user_id,
        }
    })
    
    // return NextResponse.json(user)
    return NextResponse.json({message: "Transaction Updated"})
}

export async function DELETE(req, {params}) {
    const { id } = await params

    const {game_api_id} = await req.json()
    try {
        await prisma.transaction.deleteMany({
            where: {
                AND: [
                    {
                        user_id: parseInt(id),
                    },
                    {
                        game_api_id: parseInt(game_api_id)
                    }
                ]
            }
        })

        return NextResponse.json({message: `Transaction deleted`})
    } catch (error) {
        console.log(error)
        return NextResponse.json({message: `Transaction Not Found`}, {status: 404})
    }
}