// Global variables to track state
let currentCount = 0;
let isInitialized = false;

// Function to increment the counter (when someone visits)
async function incrementCounter() {
    try {
        console.log('Incrementing counter via CountAPI...');
        
        // Use your actual domain for CountAPI namespace
        const apiUrl = 'https://api.countapi.xyz/hit/resume.csruiz.com/visits';
        
        const response = await fetch(apiUrl, {
            method: 'GET',
            mode: 'cors',
            cache: 'no-cache',
            headers: {
                'Accept': 'application/json',
            }
        });
        
        console.log('Response status:', response.status);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status} - ${response.statusText}`);
        }
        
        const data = await response.json();
        console.log('CountAPI response:', data);
        
        // Validate the response structure
        if (!data || typeof data.value === 'undefined') {
            throw new Error('Invalid response format from CountAPI');
        }
        
        // Update our local tracking
        currentCount = data.value;
        
        // Update the display
        document.getElementById('visit-count').textContent = currentCount.toLocaleString();
        document.getElementById('status').textContent = 'Live counter active';
        
        return currentCount;
        
    } catch (error) {
        console.error('Failed to increment counter:', error);
        
        // Check if we're in a local file context
        if (window.location.protocol === 'file:') {
            document.getElementById('visit-count').textContent = 'Local Preview';
            document.getElementById('status').textContent = 'Counter will work when deployed';
            return 0;
        }
        
        // For production errors, show a fallback
        document.getElementById('visit-count').textContent = 'Unavailable';
        document.getElementById('status').textContent = 'Counter service temporarily unavailable';
        
        // Log detailed error for debugging
        console.error('Error details:', {
            message: error.message,
            stack: error.stack,
            url: window.location.href,
            userAgent: navigator.userAgent
        });
        
        throw error;
    }
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', async () => {
    console.log('Page loaded, initializing counter...');
    
    try {
        // Increment counter for this visit
        await incrementCounter();
        isInitialized = true;
        console.log('Counter initialized successfully');
        
    } catch (error) {
        console.error('Failed to initialize counter:', error);
        document.getElementById('visit-count').textContent = 'Error';
        document.getElementById('status').textContent = 'Initialization failed';
    }
});