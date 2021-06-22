all:
	mkdir dist
	az group create \
		--resource-group MyDeployment \
		--location westeurope	
	az bicep build \
		-f ./main.bicep \
		--outdir dist
	az deployment group create \
		-g MyDeployment \
		--parameters @parameters.json \
		--template-file dist/main.json

clean:
	rm -rf dist
	
.PHONY: all clean
