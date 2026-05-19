FROM node:25

WORKDIR /myapp

COPY . .

RUN npm install

CMD ["npm", "start"]
