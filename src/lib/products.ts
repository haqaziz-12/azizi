export type Product = {
  slug: string; name: string; collection: string; palette: string; summary: string;
  size: string; quality: string; materials: string; washing: string; pile: string;
  description: string; images: { front: string; back: string; detail: string };
  status: "draft" | "published"; priceLabel: string;
};

// Launch concepts only. Confirm specifications and replace image placeholders before publishing.
export const products: Product[] = [
  ["heritage-medallion","Heritage Medallion","Traditional","Rich red · Ivory","A classic medallion concept inspired by Afghan ornamental traditions."],
  ["khal-mohammadi","Khal Mohammadi","Traditional","Deep red · Charcoal","A deep-toned traditional design concept with geometric motifs."],
  ["baluchi-tribal","Baluchi Tribal","Tribal","Earth · Indigo","A tribal-inspired design concept with compact repeating geometry."],
  ["afghan-geometric","Afghan Geometric","Traditional","Rust · Natural","A structured geometric concept for timeless interiors."],
  ["afghan-kilim","Afghan Kilim","Flatweave","Natural · Terracotta","A flatweave-inspired concept with a clean, tactile character."],
  ["ivory-heritage","Ivory Heritage","Neutral","Ivory · Sand","A restrained neutral concept for calm, contemporary spaces."],
  ["sapphire-tradition","Sapphire Tradition","Traditional","Sapphire · Cream","A blue-toned traditional concept with a balanced ornamental field."],
  ["emerald-afghan","Emerald Afghan","Traditional","Emerald · Warm beige","A rich green palette concept for distinctive interiors."],
  ["heritage-runner","Heritage Runner","Runner","Burgundy · Cream","An elongated format concept for corridors and transitional spaces."],
  ["round-medallion","Round Medallion","Special format","Red · Ivory","A circular medallion concept for a focused interior statement."],
  ["grand-palace","Grand Palace","Large format","Ruby · Gold","A large-format concept for generous rooms and hospitality settings."],
  ["vintage-revival","Vintage Revival","Vintage inspired","Faded rose · Stone","A softly aged visual concept with a muted palette."],
  ["modern-afghan","Modern Afghan","Contemporary","Oat · Graphite","A contemporary concept combining restrained geometry and texture."],
  ["silk-accent","Silk Accent","Premium concept","Jewel tones","A fine-detail concept; material composition must be confirmed."],
  ["bespoke-signature","Bespoke Signature","Custom","Client-selected","A custom-order concept developed around buyer requirements."],
].map(([slug,name,collection,palette,summary]) => ({
  slug, name, collection, palette, summary,
  size: "Confirm dimensions", quality: "Confirm with Uqaab team", materials: "Confirm composition",
  washing: "Care instructions to be confirmed for the actual construction", pile: "Confirm pile construction",
  description: summary + " Contact Uqaab for availability, exact specifications, and a quotation.",
  images: { front: "", back: "", detail: "" }, status: "draft", priceLabel: "Price on inquiry",
} as Product));
