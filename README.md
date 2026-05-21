# ITGrowTech

A mock test Flutter project for ITGrowTech.

## Q&A

### How you would organize a reusable verification module flow shared across multiple mobile applications?
Answer: To share a verification flow across multiple apps, the best approach is to package it as a Dart Package.

### Which architectural approaches you would use?
Answer: Clean Architecture combined with a Feature-First structure is ideal (e.g. Presentation layer, Business Logic layer, Data layer). This ensures the module remains isolated from the host app's specific business logic.

### How you would organize dependency isolation and navigation flow?
Answer: Define abstract classes in the module for external dependencies. The main app creates the implementation of verification Api and passes it to the module's entry point. Callback based navigation would be optimal for this task.