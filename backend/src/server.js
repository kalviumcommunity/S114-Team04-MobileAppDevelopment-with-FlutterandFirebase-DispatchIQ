const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;
let dispatchState = null;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'DispatchIQ Backend Running' });
});

app.get('/api/state', (req, res) => {
    res.status(200).json(dispatchState);
});

app.put('/api/state', (req, res) => {
    const { jobs, technicians } = req.body ?? {};
    if (!Array.isArray(jobs) || !Array.isArray(technicians)) {
        return res.status(400).json({
            error: 'State must include jobs and technicians arrays',
        });
    }

    dispatchState = { jobs, technicians };
    return res.status(200).json(dispatchState);
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});