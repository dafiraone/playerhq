import prisma from '../../../prismaers'
import { NextResponse } from 'next/server'
const admin = require("firebase-admin")
const serviceAccount = require("../../../playerhq-fe976-firebase-adminsdk-fbsvc-4900bc3d98.json")

// Check if the default app is already initialized to avoid reinitialization
if (admin.apps.length === 0) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    })
}

export async function GET(req) {
    const transaction = await prisma.transaction.findMany()
    return NextResponse.json(transaction, { status: 200 })
}

export async function POST(req) {
    const transactionJson = await req.json()

    try {
        await prisma.transaction.create({
            data: {
                game_api_id: transactionJson.game_api_id,
                amount: transactionJson.amount,
                user_id: transactionJson.user_id,
                status: "BERHASIL"
            }
        })

        if (transactionJson.fcmToken) {
            const msg = {
                token: transactionJson.fcmToken,
                notification: {
                    title: "PlayerHQ Purchases",
                    body: `Thanks For Purchasing ${transactionJson.game}`
                },
                android: {
                    priority: "high"
                },
                apns: {
                    payload: {
                        aps: {
                            badge: 42
                        }
                    }
                }
            }
        
            admin.messaging().send(msg).then(
                res => console.log("Success", res)
            ).catch(err => console.log("Error Sending Message", err))
        }
    } catch (error) {
        console.log(error)   
    }

    return NextResponse.json({message: "Transaction Created"}, { status: 200 })
}
