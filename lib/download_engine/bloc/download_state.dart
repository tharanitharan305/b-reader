part of 'download_bloc.dart';

sealed class DownloadState {}

final class DownloadInitial extends DownloadState {}

final class DownloadInProgress extends DownloadState {}

final class DownloadSuccess extends DownloadState {
  final String bookName;
  DownloadSuccess(this.bookName);
}

final class DownloadFailure extends DownloadState {
  final String errorMessage;
  DownloadFailure(this.errorMessage);
}

final class DownloadStatusChecked extends DownloadState {
  final bool isDownloaded;
  DownloadStatusChecked(this.isDownloaded);
}

final class OfflineBookLoaded extends DownloadState {
  final BbookModel pageModel;
  OfflineBookLoaded(this.pageModel);
}
