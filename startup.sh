
echo "Redeploying to Kubernetes..."
cd /mnt/e/Devops\ projects/Projects/testapp
kubectl apply -f k8s-service.yaml
kubectl apply -f k8s-deployment.yaml
kubectl rollout status deployment/react-app --timeout=120s

