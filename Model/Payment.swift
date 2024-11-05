// This file is part of Kiwix for iOS & macOS.
//
// Kiwix is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// any later version.
//
// Kiwix is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Kiwix; If not, see https://www.gnu.org/licenses/.

import Foundation
import PassKit
import SwiftUI
import Combine

struct Payment {

    let completeSubject = PassthroughSubject<Bool, Never>()

    static let merchantId = "merchant.org.kiwix.apple"
    static let paymentSubscriptionManagingURL = "https://www.kiwix.org"
    static let supportedNetworks: [PKPaymentNetwork] = [
        .masterCard,
        .visa,
        .discover,
        .amex,
        .chinaUnionPay,
        .electron,
        .girocard,
        .mada
    ]
    static let capabilities: PKMerchantCapability = [.threeDSecure, .credit, .debit, .emv]
    static let currencyCodes = ["USD", "EUR", "CHF"]
    static let defaultCurrencyCode = "USD"
    static let minimumAmount: Double = 5

    static let oneTimes: [AmountOption] = [
        .init(value: 10),
        .init(value: 34, isAverage: true),
        .init(value: 50)
    ]

    static let monthlies: [AmountOption] = [
        .init(value: 5),
        .init(value: 8, isAverage: true),
        .init(value: 10)
    ]

    static func paymentButtonType() -> PayWithApplePayButtonLabel? {
        if PKPaymentAuthorizationController.canMakePayments() {
            return PayWithApplePayButtonLabel.donate
        }
        if PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: Payment.supportedNetworks,
            capabilities: Payment.capabilities) {
            return PayWithApplePayButtonLabel.setUp
        }
        return nil
    }

    func donationRequest(for selectedAmount: SelectedAmount) -> PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = Self.merchantId
        request.merchantCapabilities = Self.capabilities
        request.countryCode = "CH"
        request.currencyCode = selectedAmount.currency
        request.supportedNetworks = Self.supportedNetworks
        let recurring: PKRecurringPaymentRequest? = if selectedAmount.isMonthly {
            PKRecurringPaymentRequest(paymentDescription: "payment.description.label".localized,
                                      regularBilling: .init(label: "payment.monthly_support.label".localized,
                                                            amount: NSDecimalNumber(value: selectedAmount.value),
                                                            type: .final),
                                      managementURL: URL(string: Self.paymentSubscriptionManagingURL)!)
        } else {
            nil
        }
        request.recurringPaymentRequest = recurring
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(
                label: "payment.summary.title".localized,
                amount: NSDecimalNumber(value: selectedAmount.value),
                type: .final
            )
        ]
        return request
    }

    func onPaymentAuthPhase(phase: PayWithApplePayButtonPaymentAuthorizationPhase) {
        switch phase {
        case .willAuthorize:
            break
        case .didAuthorize(_, let resultHandler):
            let result = PKPaymentAuthorizationResult(status: .success, errors: nil)
            resultHandler(result)
        case .didFinish:
            completeSubject.send(true)
        @unknown default:
            break
        }
    }

    @available(macOS 13.0, *)
    func onMerchantSessionUpdate() async -> PKPaymentRequestMerchantSessionUpdate {
        .init(status: .success, merchantSession: nil)
    }
}
