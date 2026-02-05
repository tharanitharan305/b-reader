import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/download_repo.dart';
import '../../models.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadRepo downloadRepo;

  DownloadBloc({required this.downloadRepo}) : super(DownloadInitial()) {
    on<StartDownloadEvent>(_onStartDownload);
    on<CheckDownloadStatusEvent>(_onCheckDownloadStatus);
    on<GetOfflineBookEvent>(_onGetOfflineBook);
    on<DeleteBook>(_deleteBook);
  }

  Future<void> _onStartDownload(
    StartDownloadEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(DownloadInProgress());
    try {
      await downloadRepo.downloadBook(event.pageModel);
      emit(DownloadSuccess(event.pageModel.bookName));
    } catch (e) {
      emit(DownloadFailure(e.toString()));
    }
  }

  Future<void> _onCheckDownloadStatus(
    CheckDownloadStatusEvent event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      final isDownloaded = await downloadRepo.isBookDownloaded(event.bookName);
      emit(DownloadStatusChecked(isDownloaded));
    } catch (e) {
      emit(DownloadFailure(e.toString()));
    }
  }

  Future<void> _onGetOfflineBook(
    GetOfflineBookEvent event,
    Emitter<DownloadState> emit,
  ) async {
    emit(DownloadInProgress());
    try {
      final book = await downloadRepo.getOfflineBook(event.bookName);
      if (book != null) {
        // Casting BbookModel to PageModel if they are essentially the same
        // or ensure your repo returns the correct type.
        emit(OfflineBookLoaded(book));
      } else {
        emit(DownloadFailure("Book not found offline"));
      }
    } catch (e) {
      emit(DownloadFailure(e.toString()));
    }
  }
  Future<void> _deleteBook(
      DeleteBook event,
      Emitter<DownloadState> emit,
      ) async {
    emit(DownloadInProgress());

    try {
      final deleted = await downloadRepo.deleteBook(event.bookName);

      if (deleted) {
        emit(DownloadSuccess("Deleted ${event.bookName}"));
      } else {
        emit(DownloadFailure("Book not downloaded"));
      }
    } catch (e) {
      emit(DownloadFailure(e.toString()));
    }
  }

}
