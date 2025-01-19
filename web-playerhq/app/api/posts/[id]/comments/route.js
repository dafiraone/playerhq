import prisma from '../../../../../prismaers'
import { NextResponse } from 'next/server'


export async function GET() {
    try {
        const comments = await prisma.comment.findMany()
        return NextResponse.json(comments, { status: 200 })
    } catch (error) {
        return NextResponse.json({message: "No Comments"}, { status: 200 })   
    }
}

export async function POST(req, res) {
    const { id } = await res.params

    const commentJson = await req.json()

    if (!commentJson.user_id) {
        return NextResponse.json({message: "Provide User ID"}, { status: 400 })
    } else if (!commentJson.content) {
        return NextResponse.json({message: "Comment empty"}, { status: 400 })
    }

    console.log(commentJson.user_id)
    try {
        await prisma.comment.create({
            data: {
                content: commentJson.content,
                post_id: parseInt(id),
                user_id: parseInt(commentJson.user_id),
            }
        })
    } catch (error) {
        console.log(error)
    }

    return NextResponse.json({message: "Comment Created"}, { status: 200 })
}