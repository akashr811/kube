# Use an official lightweight Node.js image
FROM node:lts-alpine
# Set the working directory to /app
WORKDIR /app 
#  Copy the files into the image at /app
COPY spotify /app
# Install http-server
RUN npm install -g http-server
# Make port 80 available to the world outside this container
EXPOSE 80
# Run http-server when the container launches
CMD ["http-server", "-p", "80"]




# Use an official lightweight Node.js image
#FROM node:lts-alpine
# Set the working directory to /app
#WORKDIR /app 
#  Copy the files into the image at /app
#COPY web /app
# Install http-server
#RUN npm install -g http-server
# Make port 80 available to the world outside this container
#EXPOSE 80
# Run http-server when the container launches


