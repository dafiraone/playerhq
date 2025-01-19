import prisma from '../../../../../../prismaers'
import {  NextResponse } from 'next/server'

export async function DELETE(req, {params}) {
    const { cid } = await params

    try {
        await prisma.comment.delete({
            where: {
                comment_id: parseInt(cid)
            }
        })
        return NextResponse.json({message: `Comment deleted`})
    } catch (error) {
        return NextResponse.json({message: `Comment Not Found`}, {status: 404})
    }

}