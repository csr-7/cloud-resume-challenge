async function updateVisitorCount() {
    console.log('=== Starting visitor count update ===');
    console.log('Current URL:', window.location.href);
    console.log('Current origin:', window.location.origin);
    
    try {
        const url = 'https://imzv9nxqq1.execute-api.us-west-1.amazonaws.com/crc-tf/visitor-count';
        console.log('Calling API URL:', url);
        console.log('Using method: POST');
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        console.log('Response status:', response.status);
        console.log('Response headers:', [...response.headers.entries()]);
        
        if (!response.ok) {
            const errorText = await response.text();
            console.error('Error response body:', errorText);
            throw new Error(`HTTP error! status: ${response.status}, body: ${errorText}`);
        }
        
        const data = await response.json();
        console.log('Success! Visitor count:', data.visitor_count);
        console.log('Full response data:', data);
        
        // Update your page with the count
        const countElement = document.getElementById('visitor-count');
        if (countElement) {
            countElement.textContent = data.visitor_count;
            console.log('Updated DOM element with count:', data.visitor_count);
        } else {
            console.warn('Element with ID "visitor-count" not found');
        }
        
    } catch (error) {
        console.error('=== ERROR in updateVisitorCount ===');
        console.error('Error type:', error.constructor.name);
        console.error('Error message:', error.message);
        console.error('Full error:', error);
    }
    
    console.log('=== Finished visitor count update ===');
}

// Call when page loads
window.addEventListener('load', () => {
    console.log('Page loaded, starting visitor count update...');
    updateVisitorCount();
});