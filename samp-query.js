const samp = require('samp-query');

const args = process.argv.slice(2);
const [host, port] = args;

if (!host || !port) {
    console.log(JSON.stringify({ error: 'Host and port required' }));
    process.exit(1);
}

const options = {
    host,
    port: parseInt(port),
    timeout: 5000
};

samp(options, (error, response) => {
    if (error) {
        console.log(JSON.stringify({ error: error.message }));
    } else {
        console.log(JSON.stringify(response));
    }
});
