import 'package:dependencies_module/dependencies_module.dart';
import 'package:flutter/material.dart';

class BodyUploadRemessaWidget extends StatelessWidget {
  const BodyUploadRemessaWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: coreModuleController.sizeH,
      child: Container(
        color: Colors.black12,
        child: Center(
          child: Obx(() {
            // if (uploadRemessaController.uploadRemessaOpsList.isNotEmpty ||
            //     uploadRemessaController.updateCsvOpsList.isNotEmpty ||
            //     uploadRemessaController.duplicadasCsvOpsList.isNotEmpty ||
            //     uploadRemessaController.uploadRemessaOpsListError.isNotEmpty) {
            //   coreModuleController.statusLoad(false);
            // } else {
            //   coreModuleController.statusLoad(true);
            // }
            return Column(
              children: <Widget>[
                _tabBar(),
                _tabBarView(),
              ],
            );
          }),
        ),
      ),
    );
  }
}

_tabBar() {
  return Container(
    height: tabHeight,
    color: Colors.red[200],
    child: TabBar(
      controller: uploadRemessaController.tabController,
      labelColor: Colors.white,
      indicatorColor: Colors.grey[800],
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      tabs: coreModuleController.showMenu
          ? uploadRemessaController.myTabsSmall
          : uploadRemessaController.myTabs,
    ),
  );
}

_tabBarView() {
  return SizedBox(
    width: coreModuleController.sizeW,
    height: coreModuleController.sizeH - tabHeight,
    child: TabBarView(
      controller: uploadRemessaController.tabController,
      children: [
        _uploadRemessaList(),
        _duplicadasRemessaList(),
        Center(),
      ],
    ),
  );
}

_uploadRemessaList() {
  final filtro = uploadRemessaController.uploadRemessaList;

  return Obx(
    () => Center(
      child: ListView.builder(
        itemCount: filtro.length,
        itemBuilder: (context, index) {
          final remessaModel = filtro[index];
          String nomeRemessa = remessaModel.nomeArquivo.length >= 100
              ? remessaModel.nomeArquivo.substring(0, 100)
              : remessaModel.nomeArquivo;
          return Center(
            child: Card(
              elevation: 0.5,
              child: SizedBox(
                width: 550,
                child: ListTile(
                  title: Text(nomeRemessa),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Data da Remessa: ${dataFormatoDDMMYYYY.format(remessaModel.data.toDate())}",
                      ),
                      Text(
                        "Data de Upload: ${dataFormatoDDMMYYYY.format(remessaModel.upload.toDate())}",
                      ),
                      Text(
                        "Quantidade de Protocolos: ${remessaModel.quantidadeProtocolos.toString()}",
                      ),
                    ],
                  ),
                  trailing: designSystemController.iconButtonPrint(
                      filtro: remessaModel),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

_duplicadasRemessaList() {
  final filtro = uploadRemessaController.duplicadasRemessaList;

  return Obx(
    () => Center(
      child: ListView.builder(
        itemCount: filtro.length,
        itemBuilder: (context, index) {
          final remessaModel = filtro[index];
          String nomeRemessa = remessaModel.nomeArquivo.length >= 100
              ? remessaModel.nomeArquivo.substring(0, 100)
              : remessaModel.nomeArquivo;
          return Center(
            child: Card(
              elevation: 0.5,
              child: SizedBox(
                width: 550,
                child: ListTile(
                  title: Text(nomeRemessa),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Data da Remessa: ${dataFormatoDDMMYYYY.format(remessaModel.data.toDate())}",
                      ),
                      Text(
                        "Data de Upload: ${dataFormatoDDMMYYYY.format(remessaModel.upload.toDate())}",
                      ),
                      Text(
                        "Quantidade de Protocolos: ${remessaModel.quantidadeProtocolos.toString()}",
                      ),
                    ],
                  ),
                  trailing: designSystemController.iconButtonPrint(
                      filtro: remessaModel),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

_uploadRemessaListError() {
  final filtro = uploadRemessaController.uploadRemessaListError;

  return Obx(
    () => Center(
      child: ListView.builder(
        itemCount: filtro.length,
        itemBuilder: (context, index) {
          final remessaModel = filtro[index];
          String nomeRemessa = remessaModel.nomeArquivo.length >= 100
              ? remessaModel.nomeArquivo.substring(0, 100)
              : remessaModel.nomeArquivo;
          return Center(
            child: Card(
              elevation: 0.5,
              child: SizedBox(
                width: 550,
                child: ListTile(
                  title: Text(nomeRemessa),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Data da Remessa: ${dataFormatoDDMMYYYY.format(remessaModel.data.toDate())}",
                      ),
                      Text(
                        "Data de Upload: ${dataFormatoDDMMYYYY.format(remessaModel.upload.toDate())}",
                      ),
                      Text(
                        "Quantidade de Protocolos: ${remessaModel.quantidadeProtocolos.toString()}",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
