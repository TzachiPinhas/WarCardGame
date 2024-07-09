import Foundation

protocol CallBack_StepDetector: AnyObject {
    func step(counter: Int)
}

class StepDetector {
    
    weak var cb: CallBack_StepDetector?
    var timer: Timer?
    
    var stepCounter = 0

    init(cb: CallBack_StepDetector) {
        self.cb = cb
    }
    
    func startSensors(steps: Int) {
        self.stepCounter = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(secondly), userInfo: nil, repeats: true)
    }
    
    @objc func secondly() {
        stepCounter += 1
        cb?.step(counter: stepCounter)
    }
    
    func stopSensors() {
        timer?.invalidate()
    }
}
