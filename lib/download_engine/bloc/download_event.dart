part of 'download_bloc.dart';

sealed class DownloadEvent {}

class StartDownloadEvent extends DownloadEvent {
  final BbookModel pageModel;
  StartDownloadEvent(this.pageModel);
}

class CheckDownloadStatusEvent extends DownloadEvent {
  final String bookName;
  CheckDownloadStatusEvent(this.bookName);
}

class GetOfflineBookEvent extends DownloadEvent {
  final String bookName;
  GetOfflineBookEvent(this.bookName);
}
class DeleteBook extends DownloadEvent{
  final String bookName;
  DeleteBook(this.bookName);

}