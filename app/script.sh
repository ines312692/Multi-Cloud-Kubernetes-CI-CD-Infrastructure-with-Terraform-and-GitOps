# À la racine de votre repo "app"
docker build -t docker.io/inestmimi123/firtsapp:v0.1.0 .
docker login -u inestmimi123
docker push docker.io/inestmimi123/firtsapp:v0.1.0
