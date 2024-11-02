
metadata author = {
	name: 'Stas Sultanov'
}

/* parameters */

param testInput string

/* variables */

/* existing resources */

/* resources */

// https://learn.microsoft.com/azure/templates/microsoft.resources/tags
@description('Tags on the resource group.')
#disable-next-line use-recent-api-versions
resource Resources_tags__Default 'Microsoft.Resources/tags@2024-03-01' = {
	name: 'default'
	properties: {
		tags: {
			test: 'test'
			test2: testInput
		}
	}
}

/* modules */

/* outputs */

output resourceGroups object = {
	Test: 'test'
	TestOutput: testInput
}
