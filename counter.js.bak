// Global variables to track state
let currentCount = 0;
let isInitialized = false;

// Function to increment the counter (when someone visits)
async function incrementCounter() {
    try {
        console.log('Incrementing counter via CountAPI...');
        
        // Make HTTP request to CountAPI to increment
        const response = await fetch('https://api.countapi.xyz/hit/resume.csruiz.com/visits');
        
        // Check if request was successful
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        // Parse the JSON response
        const data = await response.json();
        console.log('CountAPI response:', data);
        
        // Update our local tracking
        currentCount = data.value;
        
        // Update the display
        document.getElementById('visit-count').textContent = currentCount;
        document.getElementById('status').textContent = 'Connected to CountAPI';
        
        return currentCount;
        
    } catch (error) {
        console.error('Failed to increment counter:', error);
        document.getElementById('status').textContent = 'Error: Could not connect';
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