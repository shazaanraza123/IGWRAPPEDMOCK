export default async function ShareSnapshotPage({ params }) {
  const { slug } = await params
  return <main>Snapshot {slug} is not wired yet.</main>
}
