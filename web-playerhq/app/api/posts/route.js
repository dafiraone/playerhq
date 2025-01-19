import prisma from '../../../prismaers'
import { getImage, saveImage } from '../../../utils/image_utils'
import { NextResponse } from 'next/server'


export async function GET(req) {
    const posts = await prisma.post.findMany()

    for (const post of posts) {
        if (post.image) {
            post.image_base64 = getImage(post.image)
        }
    }

    return NextResponse.json(posts, { status: 200 })
}

export async function POST(req) {
    const postJson = await req.json()

    if (!postJson.user_id) {
        return NextResponse.json({message: "Provide User ID"}, { status: 400 })
    } else if (!postJson.content && !postJson.image) {
        return NextResponse.json({message: "Give something to post"}, { status: 400 })
    }
    
    if (postJson.image) {
        postJson.image = saveImage(postJson.image)
    }

    await prisma.post.create({
        data: {
            user_id: parseInt(postJson.user_id),
            content: postJson.content || null,
            image: postJson.image || null,
        }
    })

    // return NextResponse.json(user, { status: 200 })
    return NextResponse.json({message: "Post Created"}, { status: 200 })
}