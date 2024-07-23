import 'package:earnfit/configs/Singletons/singletons.dart';
import 'package:earnfit/local_storage/config_storage.dart';
import 'package:earnfit/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class InviteYourFriendsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share, color: Colors.blue),
      onPressed: () async {
        final permissionStatus = await Permission.contacts.status;

        if (!permissionStatus.isGranted) {
          _requestPermission(context);
        } else {
          Contact? contact = await _selectContact(context);
          if (contact != null && contact.phones!.isNotEmpty) {
            await _sendInvitation(context, contact);
          }
        }
      },
    );
  }

  Future<String?> fetchInvitationText() async {
    final invitationMsgText = await ConfigStorage.getInvitationMsgText();
    final appStoreLink = await ConfigStorage.getAppStoreLink();
    final playStoreLink = await ConfigStorage.getPlayStoreLink();

    if (invitationMsgText == null || (AppUtils.isAndroid && playStoreLink == null) || (!AppUtils.isAndroid && appStoreLink == null)) {
      return null; // or handle the error appropriately
    }

    final String invitationMessage;
    if (AppUtils.isAndroid) {
      invitationMessage = invitationMsgText.replaceAll('{APPLink}', playStoreLink!);
    } else {
      invitationMessage = invitationMsgText.replaceAll('{APPLink}', appStoreLink!);
    }

    return invitationMessage;
  }

  void _requestPermission(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (altertContext) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('Please grant access to contacts to use this feature.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              final contactPermissionStatus = await Permission.contacts.request();
              if (contactPermissionStatus.isGranted) {
                Navigator.pop(altertContext);
                Contact? contact = await _selectContact(context);
                if (contact != null && contact.phones!.isNotEmpty) {
                  await _sendInvitation(context, contact);
                }
              } else {
                Navigator.pop(altertContext);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<Contact?> _selectContact(BuildContext context) async {
    Iterable<Contact> contacts = await Singletons.contacts.getContactsList();
    return showContactsPicker(context, contacts);
  }

  Future<void> _sendInvitation(BuildContext context, Contact contact) async {
    String phoneNumber = contact.phones!.first.value!;
    String? invitationText = await fetchInvitationText();

    if (invitationText == null) {
      // Handle error: Invitation text not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get the invitation text')),
      );
      return;
    }

    String url = 'https://wa.me/$phoneNumber/?text=${Uri.encodeFull(invitationText)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Contact?> showContactsPicker(BuildContext context, Iterable<Contact> contacts) async {
    return await showModalBottomSheet<Contact>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              Contact contact = contacts.elementAt(index);
              return ListTile(
                title: Text(contact.displayName ?? ''),
                subtitle: Text(contact.phones!.isNotEmpty ? contact.phones!.first.value ?? '' : ''),
                onTap: () {
                  Navigator.pop(context, contact);
                },
              );
            },
          ),
        );
      },
    );
  }
}
