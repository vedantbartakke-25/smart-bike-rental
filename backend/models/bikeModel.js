// models/bikeModel.js — Raw PostgreSQL queries for bikes
const pool = require('../config/db');

const BikeModel = {
  // Get all available bikes (availability = true)
  async getAll() {
    const result = await pool.query(
      `SELECT b.*, v.name AS vendor_name, v.address AS vendor_address
       FROM bikes b
       LEFT JOIN vendors v ON b.vendor_id = v.vendor_id
       ORDER BY b.bike_id`
    );
    return result.rows;
  },

  // Get a single bike by ID
  async getById(bikeId) {
    const result = await pool.query(
      `SELECT b.*, v.name AS vendor_name, v.phone AS vendor_phone, v.address AS vendor_address
       FROM bikes b
       LEFT JOIN vendors v ON b.vendor_id = v.vendor_id
       WHERE b.bike_id = $1`,
      [bikeId]
    );
    return result.rows[0];
  },

  // Update bike availability (called after booking)
  async setAvailability(bikeId, isAvailable) {
    await pool.query(
      'UPDATE bikes SET availability = $1 WHERE bike_id = $2',
      [isAvailable, bikeId]
    );
  },
};

module.exports = BikeModel;
