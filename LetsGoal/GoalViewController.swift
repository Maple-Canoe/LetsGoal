import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

//Reference: https://stackoverflow.com/questions/61657140/how-to-create-a-popover-viewcontroller-like-apples-one

class GoalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    var handle: AuthStateDidChangeListenerHandle?
    var currentUserID: String?
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser!.uid
    
    @IBOutlet weak var welcomeUser: UILabel!
    @IBOutlet weak var goals: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var tasks : [String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tableView.dequeueReusableCell(withIdentifier: "task")! as UITableViewCell
        task.textLabel!.text = tasks[indexPath.row]
        return task
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
  
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        goals.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        goals.dataSource = self
        
        self.db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                let document = (snapshot?.documents)![0]
                if let username = document.data()["username"] as? String {
                    self.welcomeUser.text = "Welcome, \(username)!"
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTasks()
    }
    
    func fetchTasks() {
        tasks = []
        db.collection("events").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if error != nil {
                print(error!)
            } else {
                for document in (snapshot?.documents)! {
                    let event_name = document.data()["event_name"] as! String
                    self.tasks.append(event_name)
                    print(event_name)
                }
                self.goals.reloadData()
            }
        }
    }
    
    
    @IBAction func addGoal(_ sender: Any) {
        let buttonFrame = addButton.frame
        let popoverContentController = self.storyboard?.instantiateViewController(identifier: "popover") as? PopoverContentController
        popoverContentController?.modalPresentationStyle = .popover
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = self
            
            if let popoverController = popoverContentController {
                present(popoverController, animated: true, completion: nil)
            }
        }
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        fetchTasks()
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
    
    @IBAction func logOut(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
                self.view.window?.rootViewController = homeVC
                self.view.window?.makeKeyAndVisible()
            }
            catch let error {
                print(error)
            }
        }
    }
    
        
       

    
    
    
    
   
    

}
