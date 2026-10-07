const express = require('express');
const cors = require('cors');
require('dotenv').config();

const supabase = require('./supabase');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());


// =====================================================
// HEALTH CHECK
// =====================================================

app.get('/api/health', (req, res) => {
    res.status(200).json({
        status: 'DispatchIQ Backend Running'
    });
});


// =====================================================
// TECHNICIANS
// =====================================================

// Get all technicians
app.get('/api/technicians', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('technicians')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Get technician by ID
app.get('/api/technicians/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const { data, error } = await supabase
            .from('technicians')
            .select('*')
            .eq('id', id)
            .single();

        if (error) {
            return res.status(404).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Update technician status
app.put('/api/technicians/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const { data, error } = await supabase
            .from('technicians')
            .update({
                status: status
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Update technician location
app.put('/api/technicians/:id/location', async (req, res) => {
    try {
        const { id } = req.params;
        const { latitude, longitude } = req.body;

        const { data, error } = await supabase
            .from('technicians')
            .update({
                latitude: latitude,
                longitude: longitude
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// =====================================================
// SERVICE REQUESTS
// =====================================================

// Get all service requests
app.get('/api/service-requests', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('service_requests')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Get service request by ID
app.get('/api/service-requests/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const { data, error } = await supabase
            .from('service_requests')
            .select('*')
            .eq('id', id)
            .single();

        if (error) {
            return res.status(404).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Create a service request
app.post('/api/service-requests', async (req, res) => {
    try {
        const {
            customer_id,
            appliance_type,
            brand,
            model,
            issue_description,
            address,
            preferred_date,
            preferred_time,
            contact_phone
        } = req.body;

        const { data, error } = await supabase
            .from('service_requests')
            .insert([
                {
                    customer_id,
                    appliance_type,
                    brand,
                    model,
                    issue_description,
                    address,
                    preferred_date,
                    preferred_time,
                    contact_phone
                }
            ])
            .select()
            .single();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(201).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Update service request status
app.put('/api/service-requests/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const { data, error } = await supabase
            .from('service_requests')
            .update({
                status: status
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// =====================================================
// JOBS
// =====================================================

// Get all jobs
app.get('/api/jobs', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('jobs')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Get job by ID
app.get('/api/jobs/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const { data, error } = await supabase
            .from('jobs')
            .select('*')
            .eq('id', id)
            .single();

        if (error) {
            return res.status(404).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Assign technician to a job
app.post('/api/jobs/:id/assign', async (req, res) => {
    try {
        const { id } = req.params;
        const { technician_id } = req.body;

        const { data, error } = await supabase
            .from('jobs')
            .update({
                technician_id: technician_id,
                status: 'Assigned',
                assigned_at: new Date().toISOString()
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Update job status
app.put('/api/jobs/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const { data, error } = await supabase
            .from('jobs')
            .update({
                status: status
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Complete a job
app.post('/api/jobs/:id/complete', async (req, res) => {
    try {
        const { id } = req.params;

        const { data, error } = await supabase
            .from('jobs')
            .update({
                status: 'Completed',
                completed_at: new Date().toISOString()
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// =====================================================
// SERVICE HISTORY
// =====================================================

// Get all service history
app.get('/api/service-history', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('service_history')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Get service history by customer
app.get('/api/service-history/customer/:customerId', async (req, res) => {
    try {
        const { customerId } = req.params;

        const { data, error } = await supabase
            .from('service_history')
            .select('*')
            .eq('customer_id', customerId)
            .order('created_at', { ascending: false });

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Get service history by service request
app.get('/api/service-history/request/:requestId', async (req, res) => {
    try {
        const { requestId } = req.params;

        const { data, error } = await supabase
            .from('service_history')
            .select('*')
            .eq('service_request_id', requestId)
            .order('created_at', { ascending: false });

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(200).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// Create service history
app.post('/api/service-history', async (req, res) => {
    try {
        const {
            service_request_id,
            job_id,
            customer_id,
            technician_id,
            appliance_type,
            brand,
            model,
            diagnosis,
            repair_performed,
            parts_used,
            notes,
            first_time_fix,
            completed_at
        } = req.body;

        const { data, error } = await supabase
            .from('service_history')
            .insert([
                {
                    service_request_id,
                    job_id,
                    customer_id,
                    technician_id,
                    appliance_type,
                    brand,
                    model,
                    diagnosis,
                    repair_performed,
                    parts_used,
                    notes,
                    first_time_fix,
                    completed_at
                }
            ])
            .select()
            .single();

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        res.status(201).json(data);

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// =====================================================
// ANALYTICS
// =====================================================

// Dashboard analytics
app.get('/api/analytics/dashboard', async (req, res) => {
    try {

        const technicians = await supabase
            .from('technicians')
            .select('*');

        const requests = await supabase
            .from('service_requests')
            .select('*');

        const jobs = await supabase
            .from('jobs')
            .select('*');

        const history = await supabase
            .from('service_history')
            .select('*');

        res.status(200).json({
            technicians: technicians.data || [],
            service_requests: requests.data || [],
            jobs: jobs.data || [],
            service_history: history.data || []
        });

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// First-time fix analytics
app.get('/api/analytics/first-time-fix', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('service_history')
            .select('first_time_fix');

        if (error) {
            return res.status(500).json({
                error: error.message
            });
        }

        const total = data.length;

        const successful = data.filter(
            item => item.first_time_fix === true
        ).length;

        const percentage = total === 0
            ? 0
            : ((successful / total) * 100).toFixed(2);

        res.status(200).json({
            total_jobs: total,
            first_time_fixes: successful,
            first_time_fix_percentage: Number(percentage)
        });

    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});


// =====================================================
// START SERVER
// =====================================================

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});