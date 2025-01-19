import prisma from '../../../prismaers'
import { getImage, saveImage } from '../../../utils/image_utils'
import { NextResponse } from 'next/server'


export async function GET(req) {
    const users = await prisma.user.findMany()

    for (const user of users) {
        if (user.image) {
            user.image_base64 = getImage(user.image)
        }
    }

    return NextResponse.json(users, { status: 200 })
}

export async function POST(req) {
    const userJson = await req.json()

    try {

        const usernameExist = await prisma.user.findFirst({
            where: {
                username: userJson.username
            }
        })

        const emailUsed = await prisma.user.findFirst({
            where: {
                email: userJson.email
            }
        })

        if (usernameExist && usernameExist.username === userJson.username) {
            return NextResponse.json({message: "Username exist"}, {status: 409})
        } else if (emailUsed && emailUsed.email === userJson.email) {
            return NextResponse.json({message: "Email used"}, {status: 409})
        }

        if (userJson.image) {
                userJson.image = saveImage(userJson.image)
        }

        await prisma.user.create({
            data: {
                username: userJson.username,
                email: userJson.email,
                password: userJson.password,
                role: userJson.role,
                image: userJson.image || null,
                bio: userJson.bio,
            }
        })
    } catch (error) {
        console.log(error)   
    }

    // return NextResponse.json(user, { status: 200 })
    return NextResponse.json({message: "User Created"}, { status: 200 })
}