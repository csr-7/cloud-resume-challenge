const API_URL = 'https://u2ekr4m9dl.execute-api.us-west-1.amazonaws.com/crc';

        async function updateVisitorCount() {
            try {
                console.log('Fetching visitor count...');
                
                const response = await fetch(API_URL, {
                    method: 'GET',
                    headers: {
                        'Content-Type': 'application/json',
                    }
                });

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const data = await response.json();
                console.log('Visitor count data:', data);
                
                // Update the display
                document.getElementById('visitor-count').textContent = data.count;
                
            } catch (error) {
                console.error('Error fetching visitor count:', error);
                document.getElementById('visitor-count').textContent = 'Error loading count';
            }
        }

        // Update count when page loads
        document.addEventListener('DOMContentLoaded', function() {
            updateVisitorCount();
        });