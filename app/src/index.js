const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const cors = require('cors');
const os = require('os');

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 8080;
const VERSION = process.env.APP_VERSION || '1.0.0';
const ENVIRONMENT = process.env.NODE_ENV || 'development';

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json({ limit: '10mb' })); // JSON parsing
app.use(express.urlencoded({ extended: true })); // URL encoding

// Logging middleware
app.use(morgan('combined', {
    skip: (req, res) => req.url === '/health' || req.url === '/ready'
}));

// Request tracking middleware
app.use((req, res, next) => {
    req.requestId = Math.random().toString(36).substring(2, 15);
    console.log(`[${new Date().toISOString()}] ${req.requestId} - ${req.method} ${req.url} - ${req.ip}`);
    next();
});

// Health check endpoint for Kubernetes readiness/liveness probes
app.get('/health', (req, res) => {
    const healthCheck = {
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        hostname: os.hostname(),
        environment: ENVIRONMENT,
        version: VERSION,
        pid: process.pid,
        memory: process.memoryUsage(),
        cpu: process.cpuUsage()
    };

    res.status(200).json(healthCheck);
});

// Readiness check endpoint
app.get('/ready', (req, res) => {
    // Add any readiness checks here (database connections, external services, etc.)
    const readinessCheck = {
        status: 'READY',
        timestamp: new Date().toISOString(),
        checks: {
            database: 'OK', // Placeholder for actual database check
            cache: 'OK',    // Placeholder for actual cache check
            external_api: 'OK' // Placeholder for external API check
        }
    };

    res.status(200).json(readinessCheck);
});

// Main application endpoint
app.get('/', (req, res) => {
    const appInfo = {
        message: 'Hello from EKS Demo Application!',
        version: VERSION,
        environment: ENVIRONMENT,
        timestamp: new Date().toISOString(),
        hostname: os.hostname(),
        platform: os.platform(),
        architecture: os.arch(),
        nodeVersion: process.version,
        requestId: req.requestId,
        uptime: process.uptime(),
        loadAverage: os.loadavg(),
        totalMemory: `${Math.round(os.totalmem() / 1024 / 1024)} MB`,
        freeMemory: `${Math.round(os.freemem() / 1024 / 1024)} MB`,
        cpuCount: os.cpus().length
    };

    console.log(`[${new Date().toISOString()}] ${req.requestId} - Serving application info`);
    res.json(appInfo);
});

// API endpoint for testing
app.get('/api/info', (req, res) => {
    const apiInfo = {
        api: 'Demo Application API',
        version: VERSION,
        endpoints: [
            'GET / - Application information',
            'GET /health - Health check',
            'GET /ready - Readiness check',
            'GET /api/info - API information',
            'GET /api/version - Version information'
        ],
        timestamp: new Date().toISOString(),
        requestId: req.requestId
    };

    res.json(apiInfo);
});

// Version endpoint
app.get('/api/version', (req, res) => {
    res.json({
        version: VERSION,
        environment: ENVIRONMENT,
        buildTime: process.env.BUILD_TIME || 'unknown',
        gitCommit: process.env.GIT_COMMIT || 'unknown',
        requestId: req.requestId
    });
});

// 404 handler
app.use('*', (req, res) => {
    console.log(`[${new Date().toISOString()}] ${req.requestId} - 404 Not Found: ${req.originalUrl}`);
    res.status(404).json({
        error: 'Not Found',
        message: `The requested resource ${req.originalUrl} was not found`,
        timestamp: new Date().toISOString(),
        requestId: req.requestId
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(`[${new Date().toISOString()}] ${req.requestId} - Error:`, err);

    res.status(err.status || 500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'production' ? 'Something went wrong!' : err.message,
        timestamp: new Date().toISOString(),
        requestId: req.requestId
    });
});

// Graceful shutdown handler
const gracefulShutdown = (signal) => {
    console.log(`[${new Date().toISOString()}] Received ${signal}. Starting graceful shutdown...`);

    server.close((err) => {
        if (err) {
            console.error('Error during graceful shutdown:', err);
            process.exit(1);
        }

        console.log(`[${new Date().toISOString()}] Server closed. Exiting process.`);
        process.exit(0);
    });

    // Force close after 30 seconds
    setTimeout(() => {
        console.error('Forcing shutdown after 30 seconds...');
        process.exit(1);
    }, 30000);
};

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`[${new Date().toISOString()}] Demo application started`);
    console.log(`[${new Date().toISOString()}] Environment: ${ENVIRONMENT}`);
    console.log(`[${new Date().toISOString()}] Version: ${VERSION}`);
    console.log(`[${new Date().toISOString()}] Server running on port ${PORT}`);
    console.log(`[${new Date().toISOString()}] Process ID: ${process.pid}`);
    console.log(`[${new Date().toISOString()}] Node.js version: ${process.version}`);
});

// Handle termination signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
    process.exit(1);
});

// Handle unhandled rejections
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
    process.exit(1);
});

module.exports = app;
