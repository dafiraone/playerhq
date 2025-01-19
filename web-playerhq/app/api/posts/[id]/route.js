import {  NextResponse } from 'next/server'
import {saveImage, getImage, deleteImage} from '../../../../utils/image_utils'
import prisma from '../../../../prismaers'


export async function GET(req, {params}) {
    const { id } = await params

    try {

        const post = await prisma.post.findFirst({
            where: {
                post_id: parseInt(id)
            }
        })
    
        if(post.image) {
            post.image_base64 = getImage(post.image)
        }
    
        return NextResponse.json(post)
    } catch (error) {
        return NextResponse.json({message: "Post Not Found"}, {status: 404})       
    }
}

export async function PUT(req, res) {
    const { id } = await res.params

    const postJson = await req.json()

    if (!postJson.content && !postJson.image) {
        return NextResponse.json({message: "Give something to post"}, { status: 400 })
    }
    
    const currentPost = await prisma.post.findFirst({
        where: {
            post_id: parseInt(id)
        }
    })
    
    
    if (postJson.image) {
        if (currentPost.image) deleteImage(currentPost.image)
        postJson.image = saveImage(postJson.image)
    } else if (postJson.image === null) {
        if (currentPost.image) deleteImage(currentPost.image)
        postJson.image = null
        currentPost.image = null
    }
    
    await prisma.post.update({
        where: {
            post_id: parseInt(id) 
        },
        data: {
            content: postJson.content || currentPost.content,
            image: postJson.image || currentPost.image,
        }
    })
    
    // return NextResponse.json(post)
    return NextResponse.json({message: "Post Updated"})
}

export async function DELETE(req, {params}) {
    const { id } = await params

    try {
        const post = await prisma.post.delete({
            where: {
                post_id: parseInt(id)
            }
        })
        post.image ? deleteImage(post.image) : null

        return NextResponse.json({message: `Post ${post.post_id} deleted`})
    } catch (error) {
        console.log(error)
        return NextResponse.json({message: `Post Not Found`}, {status: 404})
    }

}