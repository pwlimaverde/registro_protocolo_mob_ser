import 'package:dependencies_module/dependencies_module.dart';

class CarregarRemessasFirebaseDatasource
    implements Datasource<Stream<List<RemessaModel>>> {
  @override
  Future<Stream<List<RemessaModel>>> call(
      {required ParametersReturnResult parameters}) async {
    try {
      final listaRemessas = <RemessaModel>[];
      final snapshot =
          await FirebaseFirestore.instance.collection("remessas").get();

      final teste = snapshot.docs.map((e) => e.data()).toList();
      for (Map<String, dynamic> map in teste) {
        listaRemessas.add(RemessaModel.fromMap(map));
      }

      final teste2 =
          FirebaseFirestore.instance.collection("remessas").snapshots();

      final teste3 = teste2.map((event) {
        List<RemessaModel> teste =
            event.docs.map((e) => RemessaModel.fromMap(e.data())).toList();
        return teste;
      });

      // teste3.listen((event) {
      //   print("******");
      //   print(event);
      //   print("******");
      // });

      return teste3;
    } catch (e) {
      throw Exception(
          "Erro ao carregar os dados das remessas no banco de dados");
    }
  }
}
