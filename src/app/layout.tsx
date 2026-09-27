import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Uqaab Carpet | Handcrafted Afghan Carpets", template: "%s | Uqaab Carpet" },
  description: "Discover handmade Afghan carpets by Uqaab Nawin Afghanistan Ltd. Explore traditional craftsmanship and enquire about wholesale and custom orders.",
  metadataBase: new URL("https://uqaabcarpet.com"),
  openGraph: { type: "website", siteName: "Uqaab Carpet", title: "Uqaab Carpet | Handcrafted Afghan Carpets", description: "Afghan carpet artistry, made by hand." },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
