


import UIKit
import SwiftValidator
import MRProgress

class LoginViewController: UIViewController, ValidationDelegate {
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var usernameError: UILabel!
    
    @IBOutlet weak var passwordError: UILabel!
    
    let validator = Validator()
    var groups = [CommunityGroup]()
    var savedGroups = [CommunityGroup]()
    
    override func viewDidLoad() {
        usernameError.text = ""
        passwordError.text = ""
        
        usernameField.text = GlobalUtils.loadString(Config.username)
        
        validator.registerField(usernameField, errorLabel: usernameError, rules: [RequiredRule(), EmailRule()])
        validator.registerField(passwordField, errorLabel: passwordError, rules: [RequiredRule()])
        
        navigationItem.title = "Log In"
        
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
    }
    
    func validationSuccessful() {
        let username = usernameField.text
        let password = passwordField.text
        
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        LoginUtils.login(username!, password: password!, completionHandler : {(success : Bool) in
            
            let title = success ? "Login Successful" : "Login Failed"
            
            let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alertAction) in
                if (success) {
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                }
            }))
            
            if success {
                self.loadCommunityGroups()
                LoginUtils.getUserInfo(insert: self.insertUserInfo, afterFunc: self.completeGetUserInfo)
                
            }
            
            
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true, completion: {
                self.present(alert, animated: true, completion: nil)
                
            })
        })
    }
    
    func insertUserInfo(_ dict: NSDictionary) {
        if let email = dict[UserKeys.email] as? String {
            GlobalUtils.saveString(Config.email, value: email)
        }
        if let phone = dict[UserKeys.phone] as? String {
            GlobalUtils.saveString(Config.phone, value: phone)
        }
        if let leader = dict[UserKeys.isCommunityGroupLeader] as? Bool {
            GlobalUtils.saveBool(UserKeys.isCommunityGroupLeader, value: leader)
        }
        if let notifications = dict[UserKeys.notifications] as? NSDictionary {
            if let groupNotifications = notifications[UserKeys.communityGroupUpdates] as? Bool{
                GlobalUtils.saveBool(UserKeys.communityGroupUpdates, value: groupNotifications)
            }
            if let teamNotifications = notifications[UserKeys.ministryTeamUpdates] as? Bool{
                GlobalUtils.saveBool(UserKeys.ministryTeamUpdates, value: teamNotifications)
            }
        }
    }
    
    func completeGetUserInfo(_ success: Bool) {
        //Load community groups and check if they're a leader in any of them
        CruClients.getCommunityGroupUtils().loadGroups(insertGroup, completionHandler: finishInserting)
        
    }
    
    fileprivate func insertGroup(_ dict: NSDictionary) {
        //Create group and assign its parent ministry name
        let group = CommunityGroup(dict: dict)
        self.groups.insert(group, at: 0)
    }
    
    //helper function for finishing off inserting group data
    fileprivate func finishInserting(_ success: Bool) {
        let userID = GlobalUtils.loadString(Config.userID)
        let filteredGroups = [CommunityGroup]()
        var ministryTable = CruClients.getCommunityGroupUtils().getMinistryTable()
        
        for group in groups {
            if group.leaderIDs.contains(userID) {
                group.role = "leader"
                if let parentMin = ministryTable[group.parentMinistryID] {
                    group.parentMinistryName = parentMin
                }
                savedGroups.append(group)
            }
        }
        
        
        
        
        saveCommunityGroups()
        
    }
    
    func saveCommunityGroups() {
        let newGroupData = NSKeyedArchiver.archivedData(withRootObject: savedGroups)
        UserDefaults.standard.set(newGroupData, forKey: Config.CommunityGroupsStorageKey)
    }
    
    public func loadCommunityGroups() {
        guard let groupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            return
        }
        
        guard let groupArray = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as? [CommunityGroup] else {
            print("Could not unarchive from groupData")
            return
        }
        
        savedGroups = groupArray
        
    }
    
    func resetLabel(_ field: UITextField, error: UILabel){
        field.layer.borderColor = UIColor.clear.cgColor
        field.layer.borderWidth = 0.0
        error.text = ""
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        
        var userValid = true
        var pwdValid = true
        
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = CruColors.yellow.cgColor
                field.layer.borderWidth = 1.0
                
                if(field == usernameField){
                    userValid = false
                }
                if(field == passwordField){
                    pwdValid = false
                }
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
            
            
        }
        
        if(userValid){
            resetLabel(usernameField, error: usernameError)
        }
        if(pwdValid){
            resetLabel(passwordField, error: passwordError)
        }
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        validator.validate(self)
    }
}
