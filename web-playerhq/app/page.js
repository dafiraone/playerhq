import Image from "next/image";
import Navbar from "./components/navbar";
 
export const metadata = {
  title: 'PlayerHQ User',
};

export default function Home() {
  return (
    <>
    <Navbar role="User"/>
    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col gap-8 row-start-2 items-center sm:items-start">
        <p className="text-7xl">USER PAGE</p>
      </main>
    </div>
    </>
  );
}
