const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    await prisma.product.createMany({
        data: [
            { name: 'T-Shirt', description: 'Comfy cotton T-shirt', price: 19.99, category: 'Top', sizes: ['S', 'M', 'L'], colors: ['Red', 'Blue'], images: ['url1', 'url2'] },
        ],
    });
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
}).finally(async () => {
    await prisma.$disconnect();
});
