//
//  RecordAudioViewController.swift
//  SoundMania
//
//

//importing the required Classes
import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, AVAudioRecorderDelegate {
    
    //Declaring a refrence to the lables and buttons
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordInProgress: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    //Declaring an instance of AVAudioRecorder
    var audioRecorder:AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Default func invoked which interacts with the RecordViewController
    override func viewWillAppear(_ animated: Bool) {
        
        //hide record label and stop button
        recordInProgress.isHidden = true
        stopButton.isHidden = true
        
        //enable recordButton
        recordButton.isEnabled = true
    }

    //Default func added for memoryManagement
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Perform the actual recording
    @IBAction func recordAudio(_ sender: UIButton) {
        //show text "recording in progress"
        recordInProgress.isHidden = false
        stopButton.isHidden = false
        
        //disable record button
        recordButton.isEnabled = false
        
        //build path and filename
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordingVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        //create a session and then a sessionCategory to configure the recording
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        //create recorder
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        
        //record object invoked
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()

    }

    //stop recording
    @IBAction func stopRecording(_ sender: UIButton) {
        
        //check if recorder object exists
        if (audioRecorder != nil)
        {
            //stop recording if yes
            audioRecorder.stop()
            try?
                //revoke the permissions received to record
                AVAudioSession.sharedInstance().setActive(false)
            print("Recording stopped")
        }
        else
        {
            print("Recording Not Stopped")
        }
    }
    
    //function to perform segue which accepts the recorder object as argument
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag)
        {
            //save the audio once it has stopped recording
            let recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
            
            //push the segue forward to the playSoundsViewController
            self.performSegue(withIdentifier: "stopRecording", sender: recordedAudio)
        }
        else
        {
            print("Error. Did Not Record")
            
            //revert buttons to original configuration
            recordInProgress.isHidden = true
            stopButton.isHidden = true
            recordButton.isEnabled = true
        }
    }
    
    
    //performing transition to the PlaySoundsViewController along with the audio
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "stopRecording")
        {
            let segVC = segue.destination as! PlaySoundsViewController
            segVC.recordedAudio = sender as? RecordedAudio
        }
    }
}

