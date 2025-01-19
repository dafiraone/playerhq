import fs from "fs"
import path from "path"

export function saveImage(imageBase64) {
    const IMAGE = imageBase64.replace(/^data:image\/\w+;base64,/, '')
    const IMAGE_NAME = `${Date.now()}_${Math.floor(Math.random() * 100000) + 1}.png`
    fs.writeFile(path.join(process.cwd(), 'public', 'uploads', IMAGE_NAME), IMAGE, 'base64', (err) => {
        if (err) {
            console.log(err)
        }
    })
    return IMAGE_NAME
}

export function getImage(image_path) {
    if (!fs.existsSync(path.join(process.cwd(), 'public', 'uploads', image_path))) {
        console.error(`Image not found: ${image_path}`);
        return ""
    }

    const imageBuffer = fs.readFileSync(path.join(process.cwd(), 'public', 'uploads', image_path));
    const base64Image = imageBuffer.toString('base64');
    return`data:image/png;base64,${base64Image}`
}

export function deleteImage(imageName) {
    const imagePath = path.join(process.cwd(), 'public', 'uploads', imageName)

    fs.unlink(imagePath, (err) => {
        if (err) {
            // console.error(`Error deleting image: ${err}`)
            return
        }
        // console.log(`Image ${imageName} deleted successfully.`)
    });
}