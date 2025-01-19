// import prisma from '../../../../prismaers'
import {  NextResponse } from 'next/server'
import fs from "fs"
import path from 'path'
import {saveImage, getImage, deleteImage} from '../../../../utils/image_utils'
import prisma from '../../../../prismaers'

export async function GET(req, {params}) {
    const { id } = await params

    try {
        const user = await prisma.user.findFirst({
            where: {
                user_id: parseInt(id)
            }
        })
    
        if(user.image) {
            user.image_base64 = getImage(user.image)
        }
    
        return NextResponse.json(user)
    } catch (error) {
        return NextResponse.json({message: "User Not Found"}, {status: 404})  
    }
}

export async function PUT(req, res) {
    const { id } = await res.params

    const userJson = await req.json()

    const currentUser = await prisma.user.findFirst({
        where: {
            user_id: parseInt(id)
        }
    })

    let usernameExist = null
    if (userJson.username) {
        usernameExist = await prisma.user.findFirst({
            where: {
                username: userJson.username
            }
        })
    }
    
    let emailUsed = null
    if (userJson.email) {
        emailUsed = await prisma.user.findFirst({
            where: {
                email: userJson.email
            }
        })
    }


    if (usernameExist && usernameExist.username !== userJson.username) {
        return NextResponse.json({message: "Username exist"}, {status: 409})
    } else if (emailUsed && emailUsed.email !== userJson.email) {
        return NextResponse.json({message: "Email used"}, {status: 409})
    }

    if (userJson.image) {
        if (currentUser.image) deleteImage(currentUser.image)
        userJson.image = saveImage(userJson.image)
    } else if (userJson.image === null) {
        if (currentUser.image) deleteImage(currentUser.image)
        userJson.image = null
        currentUser.image = null
    }
   
    await prisma.user.update({
        where: {
            user_id: parseInt(id) 
        },
        data: {
            username: userJson.username || currentUser.username,
            email: userJson.email || currentUser.email,
            password: userJson.password || currentUser.password,
            role: userJson.role || currentUser.role,
            image: userJson.image || currentUser.image,
            bio: userJson.bio,
        }
    })
    
    // return NextResponse.json(user)
    return NextResponse.json({message: "User Updated"})
}

export async function DELETE(req, {params}) {
    const { id } = await params
    
    try {
        const user = await prisma.user.delete({
            where: {
                user_id: parseInt(id)
            }
        })
        
        await prisma.transaction.deleteMany({
            where: {
                user_id: parseInt(id)
            }
        })

        await prisma.post.deleteMany({
            where: {
                user_id: parseInt(id)
            }
        })

        await prisma.comment.deleteMany({
            where: {
                user_id: parseInt(id)
            }
        })

        user.image ? deleteImage(user.image) : null
        return NextResponse.json({message: `User ${user.username} deleted`})
    } catch (error) {
        return NextResponse.json({message: `User Not Found`}, {status: 404})
    }
}