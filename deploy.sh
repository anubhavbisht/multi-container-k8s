docker build -t majinbisht/multi-client-k8s:latest -t majinbisht/multi-client-k8s:$SHA -f ./client/Dockerfile ./client
docker build -t majinbisht/multi-server-k8s:latest -t majinbisht/multi-server-k8s:$SHA -f ./server/Dockerfile ./server
docker build -t majinbisht/multi-worker-k8s:latest -t majinbisht/multi-worker-k8s:$SHA -f ./worker/Dockerfile ./worker

docker push majinbisht/multi-client-k8s:latest
docker push majinbisht/multi-server-k8s:latest
docker push majinbisht/multi-worker-k8s:latest

docker push majinbisht/multi-client-k8s:$SHA
docker push majinbisht/multi-server-k8s:$SHA
docker push majinbisht/multi-worker-k8s:$SHA

echo "Testing**************************"
gcloud auth activate-service-account --key-file service-account.json --quiet
gcloud container clusters get-credentials multi-cluster
kubectl config get-contexts
echo "Printing kubeconfig content:"
cat $HOME/.kube/config
echo "Testing**************************"

kubectl apply -f k8s
kubectl set image deployments/server-deployment server=majinbisht/multi-server-k8s:$SHA
kubectl set image deployments/client-deployment client=majinbisht/multi-client-k8s:$SHA
kubectl set image deployments/worker-deployment worker=majinbisht/multi-worker-k8s:$SHA