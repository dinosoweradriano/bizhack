const express = require('express');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const fs = require('fs');
const cors = require('cors')
const path = require('path');
const axios = require('axios');

const app = express();
const port = 3000;
const corsOptions = {
    origin: true, // Update this to match your client app's URL
    methods: 'GET,POST,PUT,DELETE',
    allowedHeaders: 'Content-Type,Authorization',
    optionsSuccessStatus: 200 // For legacy browser support
  };
  
  // Use the CORS middleware with the specified options
  app.use(cors(corsOptions));
// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Endpoint to receive product details and forecasted discount
    // Read the JSON file
    fs.readFile('data.json', 'utf8', (err, data) => {
        if (err) {
            console.error(`Error reading JSON file: ${err}`);
            return res.status(500).send({ error: 'Internal Server Error' });
        }

        try {
            // Parse the JSON data
            const jsonData = JSON.parse(data);
            const { Product, Quantity, 'Manufactury Date': ManufacturyDate, 'Expiry Date': ExpiryDate } = jsonData[0];

            if (!Product || !Quantity || !ManufacturyDate || !ExpiryDate) {
                return res.status(400).send({ error: 'Missing required fields' });
            }

            // Calculate the expiry_time from the dates
            const expiryTime = Math.floor((new Date(ExpiryDate) - new Date(ManufacturyDate)) / (1000 * 60 * 60 * 24));

            // Map product name to product_type
            const productTypeMapping = {
                'Apple': 0,
                'Fish': 1,
                'Yogurt': 2,
                'Milk': 3,
                'Bread': 4,
                'Orange': 5,
                'Carrot': 6,
                'Beef': 7,
                'Butter': 8,
                'Potato': 9,
                'Soda': 10,
                'Spinach': 11,
                'Broccoli': 12,
                'Chicken': 13,
                'Cookies': 14,
                'Banana': 15,
                'Juice': 16,
                'Chips': 17,
                'Shrimp': 18,
                'Tomato': 19
            };
            const productType = productTypeMapping[Product];

            if (productType === undefined) {
                return res.status(400).send({ error: 'Invalid product type' });
            }

            // Construct the command to run the Python script
            const command = `python forecats.py ${expiryTime} ${Quantity} ${productType}`;

            // Execute the Python script
            exec(command, (error, stdout, stderr) => {
                if (error) {
                    console.error(`exec error: ${error}`);
                    return res.status(500).send({ error: 'Internal Server Error' });
                }
                if (stderr) {
                    console.error(`stderr: ${stderr}`);
                    return res.status(500).send({ error: 'Internal Server Error' });
                }

                console.log(`Python script output: ${stdout.trim()}`);

            });
        } catch (err) {
            console.error(`Error parsing JSON data: ${err}`);
            return res.status(500).send({ error: 'Internal Server Error' });
        }
    });

    fs.readFile('forecasted_discount.json', 'utf8', (err, data) => {
        if (err) {
            console.error(`Error reading JSON file: ${err}`);
            return res.status(500).send({ error: 'Internal Server Error ' });
        }

        
            const jsonData1 = JSON.parse(data);
            const { forecasted_discount, product_type } = jsonData1;

            if (forecasted_discount === undefined || product_type === undefined) {
                return res.status(400).send({ error: 'Missing required fields' });
            }

            console.log(`Product Type: ${product_type}`);
            console.log(`Forecasted Discount: ${forecasted_discount}`);
            

        
    });
    app.post('/', (req, res) => {
        let { hobbies, groceries } = req.body;
      
        // Log the received data
        console.log('Received Survey Data:');
        console.log('Hobbies:', hobbies);
        console.log('Groceries:', groceries);
        console.log('Hobbies Type:', typeof hobbies);
        console.log('Groceries Type:', typeof groceries);
      
        // Convert hobbies and groceries to arrays if they are strings
        if (typeof hobbies === 'string') {
          hobbies = hobbies.split(',').map(item => item.trim());
        }
        if (typeof groceries === 'string') {
          groceries = groceries.split(',').map(item => item.trim());
        }
      
        // If the fields are empty strings, convert them to empty arrays
        hobbies = hobbies.filter(item => item);
        groceries = groceries.filter(item => item);
      
        // Create an object to store the data
        const surveyData = {
          hobbies,
          groceries
        };
      
        // Define the path to the file
        const filePath = path.join(__dirname, 'survey_data.json');
      
        // Write JSON data to a file
        fs.writeFile(filePath, JSON.stringify(surveyData, null, 2), (err) => {
          if (err) {
            console.error('Error writing to file', err);
            return res.status(500).send('Error saving survey data');
          } else {
            console.log(`File saved successfully to ${filePath}`);
            res.status(200).send('Survey data received and saved to JSON file.');
          }
        });
      });


      app.post('/data', (req, res) => {
        const { forecasted_discount, product_type, quantity, expire_time } = req.body;

        console.log('Received Data:', req.body)
    
        if (forecasted_discount === undefined || product_type === undefined || quantity === undefined || expire_time == undefined) {
            return res.status(400).send({ error: 'Missing required fields' });
        }
    
        console.log(`Received forecasted data:`);
        console.log(`Product Type: ${product_type}`);
        console.log(`Forecasted Discount: ${forecasted_discount}`);
        console.log(`Quantity: ${quantity}`);
        console.log(`Expiry Time: ${expire_time}`);

        
        


        
        storedData = { forecasted_discount, product_type, quantity, expire_time };
    
        // Further processing can be done here, such as saving data to a file or database
    
        res.status(200).send({ message: 'Data received successfully' });
    });
      const filePath_final = path.join(__dirname, 'forecasted_discount.json');


      
      // Read the JSON file
      fs.readFile(filePath_final, 'utf8', (err, data) => {
        if (err) {
          console.error('Error reading file:', err);
          return;
        }
      
        // Parse the JSON data
        const jsonData = JSON.parse(data);
      
        // Define the URL of the server to post the data to
        const serverUrl = 'http://localhost:3000/data';
      
        // Post the data to the server
        axios.post(serverUrl, jsonData)
          .then(response => {
            console.log('Data posted successfully:', response.data);
          })
          .catch(error => {
            console.error('Error posting data:', error);
          });
      });
      app.get('/data', (req, res) => {
        if (Object.keys(storedData).length === 0) {
            return res.status(404).send({ error: 'No data available' });
        }
    
        res.status(200).send(storedData);
    });

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});

//FOR VIDEO PURPOSES WE DIDNT DEPLOY FLUTTER APP ON MOBILE DEVICE