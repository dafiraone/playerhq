import { NextResponse } from 'next/server'

import GameData from "../../../gamedata"

export function GET(req) {
    // res.status(200).json({message: "Heaaaa"})

    // return new Response("Hello", {
    //     status: 200,
    //     headers: {}
    // })

    // return NextResponse.json({ message: 'Internal Server Error' }, { status: 200 })
    return NextResponse.json(GameData, { status: 200 })
}