//
//  KinAccountTests.swift
//  KinTestHostTests
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK
import Geth

class KinAccountTests: XCTestCase {

    var kinClient: KinClient!
    let passphrase = UUID().uuidString
    let node = NodeProvider(networkId: .truffle)

    var account0: KinAccount?
    var account1: KinAccount?

    override func setUp() {
        super.setUp()

        do {
            kinClient = try KinClient(provider: node)
        }
        catch {
            XCTAssert(false, "Couldn't create kinClient: \(error)")
        }

        do {
            if node.networkId == .truffle {
                account0 = try kinClient.createAccount(with: TruffleConfiguration.privateKey(at: 0),
                                                       passphrase: passphrase)

                account1 = try kinClient.createAccount(with: TruffleConfiguration.privateKey(at: 1),
                                                       passphrase: passphrase)
            }
            else if node.networkId == .ropsten {
                account0 = try kinClient.createAccount(with: passphrase)
                account1 = try kinClient.createAccount(with: passphrase)

                try obtain_kin_and_ether(for: account0!.publicAddress)
                try obtain_kin_and_ether(for: account1!.publicAddress)
            }
            else {
                XCTAssertTrue(false, "I don't know what to do with: \(node)")
            }
        }
        catch {
            XCTAssert(false, "Couldn't create accounts: \(error)")
        }
    }

    override func tearDown() {
        super.tearDown()

        kinClient.deleteKeystore()
    }

    func obtain_kin_and_ether(for publicAddress: String) throws {
        let group = DispatchGroup()
        group.enter()

        var e: Error?

        let urlString = "http://kin-faucet.rounds.video/send?public_address=\(publicAddress)"
        URLSession.shared.dataTask(with: URL(string: urlString)!) { _, _, error in
            defer {
                group.leave()
            }

            if let error = error {
                e = error

                return
            }
            }
            .resume()

        group.wait()

        if let error = e {
            throw error
        }
    }

    func test_publicAddress() {
        let expectedPublicAddress = "0x8B455Ab06C6F7ffaD9fDbA11776E2115f1DE14BD"

        let publicAddress = account0?.publicAddress

        if node.networkId == .truffle {
            XCTAssertEqual(publicAddress, expectedPublicAddress)
        }
        else {
            XCTAssertNotNil(publicAddress)
        }
    }

    func test_balance_sync() {
        do {
            let balance = try account0?.balance()

            if node.networkId == .truffle {
                XCTAssertEqual(balance, TruffleConfiguration.startingBalance)
            }
            else {
                XCTAssertNotNil(balance)
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }

    }

    func test_balance_async() {
        var balanceChecked: Balance? = nil
        let expectation = self.expectation(description: "wait for callback")

        account0?.balance { balance, _ in
            balanceChecked = balance
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5.0)

        if node.networkId == .truffle {
            XCTAssertEqual(balanceChecked, TruffleConfiguration.startingBalance)
        }
        else {
            XCTAssertNotNil(balanceChecked)
        }
    }

    func test_pending_balance() {
        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)
            let pendingBalance = try account.pendingBalance()

            XCTAssertNotNil(pendingBalance,
                            "Unable to retrieve pending balance for account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_pending_balance_async() {
        let expectation = self.expectation(description: "wait for callback")

        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)

            account.pendingBalance(completion: { balance, error in
                let bothNil = balance == nil && error == nil
                let bothNotNil = balance != nil && error != nil

                let stringBalance = String(describing: balance)
                let stringError = String(describing: error)

                XCTAssertFalse(bothNil,
                               "Only one of balance [\(stringBalance)] and error [\(stringError)] should be nil")
                XCTAssertFalse(bothNotNil,
                               "Only one of balance [\(stringBalance)] and error [\(stringError)] should be non-nil")

                expectation.fulfill()
            })
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5.0)
    }

    func test_send_transaction() {
        let sendAmount: UInt64 = 5

        do {
            guard
                let account0 = account0,
                let account1 = account1 else {
                    XCTAssertTrue(false, "No accounts to use.")
                    return
            }

            var startBalance0 = try account0.balance()
            var startBalance1 = try account1.balance()

            while startBalance0 == 0 || startBalance1 == 1 {
                sleep(1)

                startBalance0 = try account0.balance()
                startBalance1 = try account1.balance()
            }

            let txId = try account0.sendTransaction(to: account1.publicAddress,
                                                     kin: sendAmount,
                                                     passphrase: passphrase)

            XCTAssertNotNil(txId)

            // testrpc never returns
            if node.networkId != .truffle {
                while try kinClient.status(for: txId) == .pending {}
            }

            let balance0 = try account0.balance()
            let balance1 = try account1.balance()

            XCTAssertEqual(balance0, startBalance0 - Decimal(sendAmount))
            XCTAssertEqual(balance1, startBalance1 + Decimal(sendAmount))
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_insufficient_funds() {
        do {
            guard
                let account0 = account0,
                let account1 = account1 else {
                    XCTAssertTrue(false, "No accounts to use.")
                    return
            }

            let balance = try account0.balance()

            do {
                _ = try account0.sendTransaction(to: account1.publicAddress,
                                                 kin: (balance as NSDecimalNumber).uint64Value + 1,
                                                 passphrase: passphrase)
                XCTAssertTrue(false,
                              "Tried to send kin with insufficient funds, but didn't get an error")
            }
            catch {
                if let kinError = error as? KinError {
                    XCTAssertEqual(kinError, KinError.insufficientBalance)
                } else {
                    print(error)
                    XCTAssertTrue(false,
                                  "Tried to send kin, and got error, but not a KinError: \(error.localizedDescription)")
                }
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}
