# UQAAB CARPET

Premium digital home for Uqaab Nawin Afghanistan Ltd., a Kabul-based handmade Afghan carpet producer founded in 2015.

## Stack
- Next.js App Router + TypeScript
- Supabase Database, Auth, and Storage
- Cloudflare-compatible deployment (see deployment notes)

## Current status
This is the first implementation milestone: responsive public pages, a 15-concept catalogue, Supabase-backed published product reads, authenticated admin product CRUD, three image upload slots per product, contact enquiry submission, database/RLS migration, and SEO foundations. Product records are illustrative drafts: confirm all specifications, prices, and product imagery before publishing. Full editable page/site-settings management, end-to-end production QA, and deployment configuration remain follow-up work.

## Setup
1. Install Node.js 20+.
2. `npm install`
3. Copy `.env.example` to `.env.local` and fill in Supabase project URL and anon key.
4. Run the SQL in `supabase/migrations/0001_initial_schema.sql` in the Supabase SQL Editor.
5. `npm run dev`

## Important
Never expose the Supabase service-role key in client code. Public users can read only published content. Admin write access is restricted by Supabase Auth and RLS; configure an admin user and storage policies before production.

## Company contact
- Address: House #3, Opposite Ansar Hospital, Shahrak Pamir, Kotal Khair Khana, Kabul, Afghanistan
- Email: uqaab.carpet@yahoo.com
- WhatsApp: https://wa.me/93771444555
- Facebook: https://www.facebook.com/share/1ZU2fMvYiZ/
- Map: https://maps.app.goo.gl/yErNn6pui4mbvPeE7
