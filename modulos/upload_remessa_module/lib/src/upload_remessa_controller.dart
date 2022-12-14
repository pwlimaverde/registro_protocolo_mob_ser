import 'package:dependencies_module/dependencies_module.dart';
import 'package:flutter/material.dart';

import 'features/mapeamento_dados_arquivo_html/domain/usecase/mapeamento_dados_arquivo_html_usecase.dart';
import 'features/processamento_dados_arquivo_html/domain/usecase/processamento_dados_arquivo_html_usecase.dart';
import 'features/upload_remessa_firebase/domain/usecase/upload_remessa_firebase_usecase.dart';
import 'utils/errors/erros_upload_remessa.dart';
import 'utils/parametros/parametros_upload_remessa_module.dart';

class UploadRemessaController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final UploadArquivoHtmlPresenter uploadArquivoHtmlPresenter;
  final MapeamentoDadosArquivoHtmlUsecase mapeamentoDadosArquivoHtmlUsecase;
  final ProcessamentoDadosArquivoHtmlUsecase
      processamentoDadosArquivoHtmlUsecase;
  final UploadRemessaFirebaseUsecase uploadRemessaFirebaseUsecase;
  UploadRemessaController({
    required this.uploadArquivoHtmlPresenter,
    required this.mapeamentoDadosArquivoHtmlUsecase,
    required this.processamentoDadosArquivoHtmlUsecase,
    required this.uploadRemessaFirebaseUsecase,
  });

  final List<Tab> myTabs = <Tab>[
    const Tab(text: "Remessas Novas"),
    const Tab(text: "Remessas Duplicdas"),
    const Tab(text: "Remessas com erro"),
  ];

  final List<Tab> myTabsSmall = <Tab>[
    const Tab(text: "Novas"),
    const Tab(text: "Dupli."),
    const Tab(text: "Erro"),
  ];

  late TabController _tabController;

  TabController get tabController => _tabController;

  @override
  void onInit() async {
    super.onInit();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void onReady() {
    super.onReady();
    setUploadOps();
  }

  @override
  InternalFinalCallback<void> get onDelete {
    _clearLists();
    return super.onDelete;
  }

  final _uploadRemessaList = <RemessaModel>[].obs;
  final _duplicadasRemessaList = <RemessaModel>[].obs;
  final _uploadRemessaListError = <RemessaModel>[].obs;

  List<RemessaModel> get uploadRemessaList => _uploadRemessaList
    ..sort(
      (a, b) => b.data.compareTo(a.data),
    );

  List<RemessaModel> get duplicadasRemessaList => _duplicadasRemessaList
    ..sort(
      (a, b) => b.data.compareTo(a.data),
    );

  List<RemessaModel> get uploadRemessaListError => _uploadRemessaListError
    ..sort(
      (a, b) => b.data.compareTo(a.data),
    );

  void _clearLists() {
    uploadRemessaList.clear();
    duplicadasRemessaList.clear();
    uploadRemessaListError.clear();
  }

  Future<void> setUploadOps() async {
    _clearLists();
    _uploadRemessas(
      novasRemessas: await _processamentoDados(
        listaMapBruta: await _mapeamentoDadosArquivo(
          listaMapBytes: await _carregarArquivos(),
        ),
      ),
    );
  }

  Future<List<Map<String, Uint8List>>> _carregarArquivos() async {
    final arquivos = await uploadArquivoHtmlPresenter(
      parameters: NoParams(
        error: ErroUploadArquivo(
          message: "Erro ao Erro ao carregar os arquivos.",
        ),
        showRuntimeMilliseconds: true,
        nameFeature: "Carregamento de Arquivo",
      ),
    );
    if (arquivos.status == StatusResult.success) {
      return arquivos.result;
    } else {
      coreModuleController.message(
        MessageModel.error(
          title: 'Carregamento de arquivos',
          message: 'Erro ao carregar os arquivos',
        ),
      );
      throw Exception("Erro ao carregar os arquivos");
    }
  }

  Future<List<Map<String, Map<String, dynamic>>>> _mapeamentoDadosArquivo(
      {required List<Map<String, Uint8List>> listaMapBytes}) async {
    final mapeamento = await mapeamentoDadosArquivoHtmlUsecase(
      parameters: ParametrosMapeamentoArquivoHtml(
        error: ErroUploadArquivo(
          message: "Erro ao mapear os arquivos.",
        ),
        nameFeature: 'Mapeamento Arquivo',
        showRuntimeMilliseconds: true,
        listaMapBytes: listaMapBytes,
      ),
    );
    if (mapeamento.status == StatusResult.success) {
      return mapeamento.result;
    } else {
      coreModuleController.message(
        MessageModel.error(
          title: 'Mapeamento de arquivos',
          message: 'Erro ao mapear os arquivos.',
        ),
      );
      throw Exception("Erro ao mapear os arquivos.");
    }
  }

  Future<List<RemessaModel>> _processamentoDados({
    required List<Map<String, Map<String, dynamic>>> listaMapBruta,
  }) async {
    final remessasProcessadas = await processamentoDadosArquivoHtmlUsecase(
      parameters: ParametrosProcessamentoArquivoHtml(
        error: ErroUploadArquivo(
          message: "Erro ao processar Arquivo",
        ),
        nameFeature: 'Processamento Arquivo',
        listaMapBruta: listaMapBruta,
        showRuntimeMilliseconds: true,
      ),
    );

    if (remessasProcessadas.status == StatusResult.success) {
      final List<RemessaModel> listRemessa =
          remessasProcessadas.result["remessasProcessadas"];
      final List<RemessaModel> listRemessaError =
          remessasProcessadas.result["remessasProcessadasError"];
      final List<RemessaModel> listRemessasDuplicadas = [];
      final List<RemessaModel> listRemessasNovas = [];

      for (RemessaModel remessa in listRemessa) {
        final consultaRemessa = remessasController.listTadasRemessas.where(
          (element) => element.nomeArquivo == remessa.nomeArquivo,
        );
        if (consultaRemessa.isEmpty) {
          listRemessasNovas.add(remessa);
        } else {
          listRemessasDuplicadas.add(remessa);
        }
      }
      coreModuleController.message(
        MessageModel.info(
          title: "Processamento de Remessa",
          message:
              "${listRemessa.length} Processadas com Sucesso! \n ${listRemessasNovas.length} Nova(s) Ressa(s)! \n ${listRemessasDuplicadas.length} Remessas Duplicadas! \n ${listRemessaError.length} Processadas com Erro!",
        ),
      );
      if (listRemessasDuplicadas.isNotEmpty) {
        _duplicadasRemessaList(listRemessasDuplicadas);
      }
      if (listRemessaError.isNotEmpty) {
        _uploadRemessaListError(listRemessaError);
      }
      if (listRemessasNovas.isNotEmpty) {
        return listRemessasNovas;
      } else {
        coreModuleController.message(
          MessageModel.info(
            title: 'Processamento de Remessa',
            message: 'Nenhuma Remessa Nova a ser processada!',
          ),
        );
        return <RemessaModel>[];
      }
    } else {
      coreModuleController.message(
        MessageModel.error(
          title: 'Processamento de Remessa',
          message: 'Erro ao processar as Remessa!',
        ),
      );
      return <RemessaModel>[];
    }
  }

  Future<void> _uploadRemessas({
    required List<RemessaModel> novasRemessas,
  }) async {
    try {
      if (novasRemessas.isNotEmpty) {
        final Iterable<Future<RemessaModel>> enviarRemessasFuturo =
            novasRemessas.map(_enviarNovaRemessa);

        final Future<Iterable<RemessaModel>> waited =
            Future.wait(enviarRemessasFuturo);

        await waited;
        _uploadRemessaList(novasRemessas);
        coreModuleController.message(
          MessageModel.info(
            title: "Upload de Remessa",
            message: "Upload de ${novasRemessas.length} Remessa com Sucesso!",
          ),
        );
      }
    } catch (e) {
      coreModuleController.message(
        MessageModel.error(
          title: 'Upload de Remessa',
          message: 'Erro ao fazer o Upload da Remessa!',
        ),
      );
      throw Exception("Erro ao fazer o Upload da Remessa!");
    }
  }

  Future<RemessaModel> _enviarNovaRemessa(RemessaModel model) async {
    final uploadFirebase = await uploadRemessaFirebaseUsecase(
      parameters: ParametrosUploadRemessa(
        remessaUpload: model,
        error: ErroUploadArquivo(
            message:
                "Erro ao fazer o upload da Remessa para o banco de dados!"),
        showRuntimeMilliseconds: true,
        nameFeature: "upload firebase",
      ),
    );

    if (uploadFirebase.status == StatusResult.success) {
      return model;
    } else {
      coreModuleController.message(
        MessageModel.error(
          title: 'Upload de Remessa Firebase',
          message: 'Erro enviar a remessa para o banco de dados!',
        ),
      );
      throw Exception("Erro enviar a remessa para o banco de dados!");
    }
  }
}
