
// Create (POST)
async function createItem(data) {
  try {
    const res = await fetch(API_BASE, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    if (!res.ok) throw new Error(`Create failed: ${res.status}`);
    return await res.json(); 
  } catch (err) {
    console.error(err);
    throw err;
  }
}

// Read (GET all or by id)
async function getItems() {
  const res = await fetch(API_BASE);
  if (!res.ok) throw new Error('Failed to fetch items');
  return await res.json();
}
async function getItemById(id) {
  const res = await fetch(`${API_BASE}/${id}`);
  if (!res.ok) throw new Error('Failed to fetch item');
  return await res.json();
}

// Update (PUT or PATCH)
async function updateItem(id, data) {
  try {
    const res = await fetch(`${API_BASE}/${id}`, {
      method: 'PUT', 
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    if (!res.ok) throw new Error(`Update failed: ${res.status}`);
    return await res.json();
  } catch (err) {
    console.error(err);
    throw err;
  }
}

// Delete (DELETE)
async function deleteItem(id) {
  try {
    const res = await fetch(`${API_BASE}/${id}`, {
      method: 'DELETE'
    });
    if (!res.ok) throw new Error(`Delete failed: ${res.status}`);
    return await res.json(); 
  } catch (err) {
    console.error(err);
    throw err;
  }
}
