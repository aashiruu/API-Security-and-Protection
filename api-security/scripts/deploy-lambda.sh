```bash
#!/bin/bash
# Script to package and deploy Lambda function

echo "Packaging Lambda function..."

cd lambda-function
zip -r ../lambda-function.zip .
cd ..

echo "Lambda function packaged as lambda-function.zip"
echo "Run 'terraform apply' to deploy the complete infrastructure"
```
