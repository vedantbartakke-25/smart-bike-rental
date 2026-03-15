// controllers/bikeController.js — List & get bikes
const BikeModel = require('../models/bikeModel');

// ── GET /api/bikes ───────────────────────────────────────────
const getAllBikes = async (req, res) => {
  try {
    const bikes = await BikeModel.getAll();
    res.json({ bikes });
  } catch (err) {
    console.error('getAllBikes error:', err.message);
    res.status(500).json({ error: 'Failed to fetch bikes.' });
  }
};

// ── GET /api/bikes/:id ───────────────────────────────────────
const getBikeById = async (req, res) => {
  try {
    const { id } = req.params;

    // Validate numeric ID
    if (isNaN(id)) {
      return res.status(400).json({ error: 'Bike ID must be a number.' });
    }

    const bike = await BikeModel.getById(id);
    if (!bike) {
      return res.status(404).json({ error: 'Bike not found.' });
    }

    res.json({ bike });
  } catch (err) {
    console.error('getBikeById error:', err.message);
    res.status(500).json({ error: 'Failed to fetch bike.' });
  }
};

module.exports = { getAllBikes, getBikeById };
