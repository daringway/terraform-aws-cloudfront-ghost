'use strict';

// Sample code from https://docs.aws.amazon.com/lambda/latest/dg/nodejs-handler.html

var customErrorPage = `
<!DOCTYPE html>
<html>
<head>
    <title>Centered Content with Border</title>
    <style>
        .centered-content {
            margin: 0 auto;
            width: 50%; /* Adjust width as needed */
            border: 2px solid black; /* Adjust border style as needed */
            padding: 20px; /* Adjust padding as needed */
            text-align: center;
            box-sizing: border-box;
            font-size: large;
        }
    </style>
</head>
<body>

<div class="centered-content">
    <!-- Your content goes here -->
    <p>Site is being upgraded just for you.</p>
</div>

</body>
</html>`;


exports.handler = (event, context, callback) => {
    const response = event.Records[0].cf.response;

    /**
     * This function updates the response status to 200 and generates static
     * body content to return to the viewer in the following scenario:
     * 1. The function is triggered in an origin response
     * 2. The response status from the origin server is an error status code (4xx or 5xx)
     */

    if (response.status >= 500 && response.status <= 504) {
        response.status = 503;
        response.statusDescription = 'Site is under maintenance';
        response.body = customErrorPage;
    }

    callback(null, response);
};

// exports.handler = (event, context, callback) => {
//     const response = event.Records[0].cf.response;
//
//     // Check if the status code is 502
//     if ([502].includes(response.statusCode) ) {
//
//         var customErrorPage = `
//             <html>
//                 <head>
//                     <title>Site is Being Upgraded</title>
//                 </head>
//                 <body>
//                     <h1>Sorry, the page is currently unavailable.</h1>
//                 </body>
//             </html>`;
//
//
//         const response = {
//         status: '503',
//         statusDescription: 'Down for Maintenance',
//
//         response.status = '503';
//         response.body = customErrorPage;
//
//     }
//
//     callback(null, response);
// }
//
