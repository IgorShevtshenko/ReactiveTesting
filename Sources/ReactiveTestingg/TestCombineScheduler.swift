import Combine
import XCTest

public extension XCTestCase {

    func testScheduler<P: Publisher>(
        timeout: TimeInterval,
        publisher: P
    ) -> TestCombineScheduler<P> {
        TestCombineScheduler(timeout: timeout, testCase: self, publisher: publisher)
    }
}

public class TestCombineScheduler<EventsPublisher: Publisher> {

    private let timeout: TimeInterval
    private let publisher: EventsPublisher

    private let testCase: XCTestCase
    private let expectation: XCTestExpectation

    private let dispatchQueue = DispatchQueue.main
    private let initialDispatchTime: DispatchTime

    private var results = [EventsPublisher.Output]()
    private var error: EventsPublisher.Failure?
    private var cancellables = Set<AnyCancellable>()

    public init(timeout: TimeInterval, testCase: XCTestCase, publisher: EventsPublisher) {
        self.timeout = timeout
        self.publisher = publisher
        self.testCase = testCase
        expectation = testCase.expectation(description: "\(type(of: self)) timeout expectation")
        initialDispatchTime = .now()

        setupPublisherSubscription()
        scheduleCancellation()
    }

    public func scheduleEvent(deadline: TimeInterval, event: @escaping () -> Void) {
        dispatchQueue.asyncAfter(deadline: initialDispatchTime + deadline, execute: event)
    }

    public func finish() {
        cancellables = []
    }

    public func receive(_ resultsHandler: @escaping ([EventsPublisher.Output]) -> Void) {
        testCase.waitForExpectations(timeout: timeout + 0.01) { [weak self] _ in
            guard let results = self?.results else {
                fatalError("Results not found")
            }
            resultsHandler(results)
        }
    }

    public func receiveFailure(_ failureHandler: @escaping (EventsPublisher.Failure) -> Void) {
        testCase.waitForExpectations(timeout: timeout + 0.01) { [weak self] _ in
            guard let error = self?.error else {
                fatalError("Error not found")
            }
            failureHandler(error)
        }
    }

    private func setupPublisherSubscription() {
        publisher
            .handleEvents(receiveCancel: expectation.fulfill)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.error = error
                        self?.expectation.fulfill()
                    case .finished:
                        self?.expectation.fulfill()
                    }
                },
                receiveValue: { [weak self] in self?.results.append($0) }
            )
            .store(in: &cancellables)
    }

    private func scheduleCancellation() {
        dispatchQueue.asyncAfter(deadline: initialDispatchTime + timeout) {
            self.cancellables = []
        }
    }
}
