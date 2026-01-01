import SwiftUI

struct CustomDurationPickerView: View {
    @Binding var customMinutes: Int
    @Binding var isPresented: Bool
    var onConfirm: (Int) -> Void
    
    var body: some View {
        VStack {
            Picker("Minutes", selection: $customMinutes) {
                ForEach(1...180, id: \.self) { minute in
                    Text("\(minute) min").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
        }
        .navigationTitle("Set Duration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(.secondary)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    onConfirm(customMinutes)
                    isPresented = false
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow)
            }
        }
    }
}
