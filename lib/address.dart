import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

class EditAddressPage extends StatefulWidget {
  final String currentAddress;
  const EditAddressPage({Key? key, required this.currentAddress})
      : super(key: key);
  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController sectorController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
              ),
              onTap: () async {
                // Open location search and autocomplete
                Prediction? prediction = await PlacesAutocomplete.show(
                  context: context,
                  apiKey:
                      'AIzaSyC8MMVIRrer87cYv1jL_BD9x8yNA8JVHQc', // Replace with your own Google Places API key
                  mode: Mode.overlay, // Show as a fullscreen overlay
                );

                if (prediction != null && prediction.description != null) {
                  // Update the address controller with the selected prediction
                  setState(() {
                    addressController.text = prediction.description!;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: sectorController,
              decoration: const InputDecoration(
                labelText: 'Sector',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'City',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Save the edited address details to the database

                // Pass the updated address back to the CartPage
                Navigator.pop(context, addressController.text);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    addressController.text = widget.currentAddress;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    sectorController.dispose();
    cityController.dispose();
    super.dispose();
  }
}
