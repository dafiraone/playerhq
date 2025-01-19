// prisma.js (or prisma.ts if using TypeScript)
import { PrismaClient } from '@prisma/client'

// This ensures that PrismaClient is only created once during the lifecycle of the app
if (process.env.NODE_ENV === 'production') {
  prisma = new PrismaClient()
} else {
  // In development mode, PrismaClient is created once, but reused across hot reloads
  if (!global.prisma) {
    global.prisma = new PrismaClient()
  }
  prisma = global.prisma
}

export default prisma
