import ClockKit
import Shared

/// Provides complications across the modular, circular, and corner families.
/// In production the latest gate/door state is read from the App Group shared
/// container so the complication can update without launching the Watch app.
final class ComplicationController: NSObject, CLKComplicationDataSource {
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "gate_state",
                displayName: "Gate State",
                supportedFamilies: [
                    .modularSmall,
                    .circularSmall,
                    .graphicCircular,
                    .graphicCorner,
                ]
            ),
        ]
        handler(descriptors)
    }

    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        let template: CLKComplicationTemplate
        switch complication.family {
        case .graphicCorner:
            let cornerTemplate = CLKComplicationTemplateGraphicCornerStackText(
                innerTextProvider: CLKSimpleTextProvider(text: "Gate"),
                outerTextProvider: CLKSimpleTextProvider(text: latestGateState())
            )
            template = cornerTemplate
        default:
            let modularTemplate = CLKComplicationTemplateModularSmallSimpleText(
                textProvider: CLKSimpleTextProvider(text: latestGateState())
            )
            template = modularTemplate
        }
        let entry = CLKComplicationTimelineEntry(date: .now, complicationTemplate: template)
        handler(entry)
    }

    private func latestGateState() -> String {
        // Read from App Group UserDefaults in production; stub here.
        return "Closed"
    }
}
