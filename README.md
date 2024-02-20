# Core Data Project
This project allows you to create, fetch, update, and delete person objects (CRUD). I created a Core Data Stack class instead of relying on the app delegate for core data functionality. Multiple contexts are used: the main context is used for loading the person objects and updating the UI, while the private context is used for updated, creating, and deleting objects on the background thread, as well as syncing with the main context. The 'PersonProvider' class is responsible for communicating with the CoreDataStack and View Controller. I built this demo with SOLID principles in mind. Other approaches used: MVC, async-await, and delegate pattern. The file structure for this one is different from what I've used previously. It was inspired by the example starter project I saw in this [Poke API GraphQL tutorial](https://www.delasign.com/blog/swift-graphql-call/).
- Tap on the add button (upper right) to added an entry.
- Swipe a cell to delete a entry. 
- Tap one of the table cells to be prompted with updating an entry. 
- Tap on the accessory button to be presented with a detail view controller that will display the person's name, gender, and age.


# GIF Example
![Demo](https://github.com/AshleyCanty/CoreDataListDemo/blob/main/CoreDataListDemo-example.gif)
