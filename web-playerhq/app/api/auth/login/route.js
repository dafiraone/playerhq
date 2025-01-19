import prisma from '../../../../prismaers'
import { getImage } from '../../../../utils/image_utils'
import { NextResponse } from 'next/server'


export async function POST(req) {
    const userJson = await req.json()

    try {
        const user = await prisma.user.findFirst({
            where: {
                username: userJson.username
            }
        })

        if (user.image) {
            user.image_base64 = getImage(user.image)
        }

        if (user.password === userJson.password) return NextResponse.json(user, { status: 200 })
        else return NextResponse.json({message: "Password wrong"}, { status: 401 })
    } catch (error) {
        return NextResponse.json({message: "User Not Found"}, { status: 404 })
    }

}