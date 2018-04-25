//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//

//importing the required Classes
import UIKit
import AVFoundation
import MessageUI

//inherting the modules from the Classes
class PlaySoundsViewController: UIViewController, MFMailComposeViewControllerDelegate, AVAudioRecorderDelegate  {
    
    //Declaring an object of RecordedAudio
    var recordedAudio: RecordedAudio?

    //Declaring an object of audioRatePitch
    var audioRatePitch: AVAudioUnitTimePitch!
    
    //Declating an object of AVAudioEngine
    var audioEngine: AVAudioEngine!
    
    //Declaring an object of AVAudioPlayerNode
    var audioPlayerNode: AVAudioPlayerNode!
    
    //Declating an object of AVAudioFile
    var audioFile: AVAudioFile!
    
    //reference to the activity borderView
    @IBOutlet weak var borderView: UIImageView!
    
    //reference to the slowRate as snailButton
    @IBOutlet weak var snailButton: UIImageView!
    
    //refence to the fastRate as rabbitButton
    @IBOutlet weak var rabbitButton: UIImageView!
    
    //reference to the highPitch as chipmunkButton
    @IBOutlet weak var chipmunkButton: UIImageView!
    
    //reference to the lowPitch as vaderButton
    @IBOutlet weak var vaderButton: UIImageView!
    
    //reference to the postion of the node
    @IBOutlet weak var touchPosition: UIImageView!
    
    //reference to the resetButton
    @IBAction func resetButton(_ sender: Any) {
        touchPosition.center.x = borderView.center.x
       
        touchPosition.center.y=borderView.center.y
        
        
    }
    
    //setting the contraint of rate and pitch
    let MIN_RATE: Float = 0.5
    let MAX_RATE: Float = 2.0
    let MIN_PITCH: Float = -1000
    let MAX_PITCH: Float = 1000
    
    //Default func invoked which interacts with the RecordViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup border for touch area
        borderView.layer.borderColor = UIColor(red: 33/255, green: 73/255, blue: 111/255, alpha: 1.0).cgColor
        borderView.layer.borderWidth = 2.0
        
        if recordedAudio != nil
        {
            print("!!!good!!!")
            
            let audioUrl = recordedAudio!.getFilePathUrl()
            
            //invoke audio engine and attach pitch-effect and player
            audioEngine = AVAudioEngine()
            
            //connecting the rate and pitch to the audioEngine
            audioRatePitch = AVAudioUnitTimePitch()
            
            //connecting the node to the audioEngine
            audioPlayerNode = AVAudioPlayerNode()
            
            //connecting the node to the rate and pitch for dynamic changes
            audioEngine.attach(audioRatePitch)
            
            //connecting the node to the audioEngine
            audioEngine.attach(audioPlayerNode)
            
            //connecting the node to the rate and pitch for dynamic changes
            audioEngine.connect(audioPlayerNode, to: audioRatePitch, format: nil)
            
            //a reference to set the values of rate and pitch with respect to the position of the node
            audioEngine.connect(audioRatePitch, to: audioEngine.outputNode, format: nil)
            
            //check if the audio file has been received
            do{
                audioFile = try AVAudioFile(forReading: audioUrl as URL)
            }catch{}
            
            try? audioEngine.start()
        }
        else
        {
            print("WARNING: Resource not found!")
        }
    }
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    //stop playing when clicked
    @IBAction func stopPlay(_ sender: UIButton) {
        audioPlayerNode.stop()
    }
    
    //start playing when clicked
    @IBAction func playAudio(_ sender: AnyObject) {
        playAudio()
    }
    
    //change the postion of the node if tapped on the activity screen
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        print("Tapping: \(sender.location(in: self.view))")
        updateOnUserInput(sender.location(in: self.view))
    }
    
    //change the postion of the node if dragged on the activity screen
    @IBAction func viewDragged(_ sender: UIPanGestureRecognizer) {
        if sender.state == .changed
        {
            print("Dragging: \(sender.location(in: self.view))")
            updateOnUserInput(sender.location(in: self.view))
        }
    }
    
    //custom functions to retrive the position of the node
    func updateOnUserInput(_ position: CGPoint) {
        touchPosition.layer.zPosition = .greatestFiniteMagnitude
        let x = position.x
        let y = position.y
        if (coordinateInsideButtonRect(x, y: y)) {
            touchPosition.center.x = x
            touchPosition.center.y = y
            
            //setting the value of the pitch
            let pitch = getPitchValueFromTouchLocation(Float(x))
            
            //setting the value of the rate
            let rate = getRateValueFromTouchLocation(Float(y))
            
            print("Pitch: \(pitch)")
            print("Rate: \(rate)")
            
            //using the values of pitch and rate
            audioRatePitch.pitch = pitch
            audioRatePitch.rate = rate
            
        }
    }
    
    //adding constraits to the border of the screen
    func coordinateInsideButtonRect(_ x: CGFloat, y: CGFloat) -> Bool {
        if ((x < borderView.center.x - borderView.frame.size.width / 2) || (y < borderView.center.y - borderView.frame.size.height / 2) || (x > borderView.center.x + borderView.frame.size.width / 2) || (y > borderView.center.y + borderView.frame.size.height / 2)) {
            return false
        }
        
        return true
    }
    
    //setting the constaint to the value of Pitch
    func getPitchValueFromTouchLocation(_ x: Float) -> Float {
        let MIN_PITCH: Float = -1000
        let MAX_PITCH: Float = 1000
        
        let X_MIN = Float(borderView.center.x - borderView.frame.size.width / 2)
        let X_MAX = Float(borderView.center.x + borderView.frame.size.width / 2)
        
        return remapToInterval(MIN_PITCH, targetHigh: MAX_PITCH, srcLow: X_MIN, srcHigh: X_MAX, srcValue: x)
    }
    
    //setting the constraint to the value of Rate
    func getRateValueFromTouchLocation(_ y: Float) -> Float {
        let MIN_RATE: Float = 0.5
        let MAX_RATE: Float = 2.0
        
        let Y_MIN = Float(borderView.center.y - borderView.frame.size.height / 2)
        let Y_MAX = Float(borderView.center.y + borderView.frame.size.height / 2)
        
        return remapToInterval(MIN_RATE, targetHigh: MAX_RATE, srcLow: Y_MIN, srcHigh: Y_MAX, srcValue: y)
    }
    
    //changing the voice with the values of rate and pitch
    func remapToInterval(_ targetLow: Float, targetHigh: Float, srcLow: Float, srcHigh: Float, srcValue: Float) -> Float {
        return (targetLow - targetHigh) * (srcValue - srcHigh) / (srcLow - srcHigh) + targetHigh
    }
    
    //playing audio when repressed
    func playAudio() {
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        audioPlayerNode.play()
        
    }
    
    // var audioRecorder1:AVAudioRecorder!
    
    //setting up the transition to the mailScreen
    @IBAction func sendEmail(_ sender: Any) {
        let mailComposeViewController = configureMailController(attachmentURL: "recordingVoice.wav")
        if MFMailComposeViewController.canSendMail(){
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            mailShowError()
        }
    }
    
    //setting the transisiton to the mailScreen
    func configureMailController(attachmentURL: String) -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        //mailComposerVC.setToRecipients(["arthurcutillo@gmail.com"])
        
        //setting the mailSubject
        mailComposerVC.setSubject("soundMania Recording")
        
        //setting the mailBody
        mailComposerVC.setMessageBody("Check out my soundMania!!", isHTML: false)
        
        //retrive the saved voice from the directory
        if let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as? String {
            let fileManager = FileManager.default
            let filecontent = fileManager.contents(atPath: docsDir + "/" + "recordingVoice.wav")
            mailComposerVC.addAttachmentData(filecontent!, mimeType: "audio/x-wav", fileName: "recordingVoice")
        }
        return mailComposerVC
    }
    
    //handle error when sending mail
    func mailShowError(){
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title:"OK", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated:true, completion: nil)
        
    }
    
    //shows the mail composer
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil) //returns back once mail is clicked
    }
    
    //storing the modulated voice in the local memory
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag)
        {
            //step 1 - save recorded audio
            let recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
            
            //step 2 - navigate to second view
            self.performSegue(withIdentifier: "stopRecording", sender: recordedAudio)
        }
        else
        {
            print("WARNING: Recording not successfull")
        }
    }
}
