import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';


export 'package:contacts_service/contacts_service.dart' show Contact;

class Contacts {
  const Contacts();

  Future<List<Contact>> getContactsList() async {
    try {
      return await ContactsService.getContacts(
        withThumbnails: false,
        photoHighResolution: false,
      );
    } catch (exception, stackTrace) {
      rethrow;
    }
  }
}
