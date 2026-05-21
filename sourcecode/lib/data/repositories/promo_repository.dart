import 'package:dio/dio.dart';
import 'package:itgrowtech/data/api/api.dart';
import 'package:xml/xml.dart';

class PromoRepository {
  final Api _api = Api();

  Future<List<List<String?>>> getPromos() async {
    try{
      const body = '''
        <?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <GetCCPromo xmlns="http://tempuri.org/">
              <lang>en</lang>
            </GetCCPromo>
          </soap:Body>
        </soap:Envelope>
        ''';

      final response = await _api.makeApiCall.post(
        'https://api-forexcopy.contentdatapro.com/Services/CabinetMicroService.svc',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction':
                'http://tempuri.org/ICabinetMicroService/GetCCPromo',
          },
          responseType: ResponseType.plain,
          connectTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final xml = XmlDocument.parse(response.data);

      final promos = xml.findAllElements('CCPromo');

      return promos.map((item) {
        final title = item.getElement('Title')?.innerText;

        final image = item
            .getElement('Image')
            ?.innerText
            .replaceAll(
              'forex-images.instaforex.com',
              'forex-images.ifxdb.com',
            );

        final link = item.getElement('Link')?.innerText;

        return [title, image, link];

      }).toList();
    } on DioException {
      rethrow;
    }

  }

}


