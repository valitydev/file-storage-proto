namespace java com.rbkmoney.file.storage
namespace erlang file_storage

// время
typedef string Timestamp
// id файла
typedef string FileId
// ссылка на файл
typedef string URL
// дополнительная информация о файле
typedef map<string, string> Metadata

exception FileNotFound {}

struct FileData {
    // имя документа
    1: required string name,
    // дата загрузки документа
    2: required Timestamp created_at
    // дополнительная информация о файле
    3: required Metadata metadata
}

/*
* Сервис для загрузки и выгрузки файлов
* */
service FileStorage {

    /*
    * Создать пустой файл в хранилище
    * file_data - данные о файле, которые сохраняются как метаданные при создании пустого файла
    *
    * Возвращает id файла
    * */
    FileId CreateEmptyFile (1: FileData file_data)

    /*
    * Получить данные о файле
    * file_id - id файла
    *
    * Возвращает данные о файле, которые хранятеся как метаданные файла
    *
    * FileNotFound - файл не найден
    * */
    FileData GetFileData (1: FileId file_id)
        throws (1: FileNotFound ex1)

    /*
    * Сгенерировать ссылку на файл для выгрузки на сервер
    * file_id - id файла
    *
    * Возвращает ссылку на файл для дальнейшей выгрузки на сервер
    *
    * FileNotFound - файл не найден
    * */
    URL GenerateUploadUrl (1: FileId file_id)
        throws (1: FileNotFound ex1)

    /*
    * Сгенерировать ссылку на файл для загрузки с сервера
    * file_id - id файла
    * expires_at - время до которого ссылка будет считаться действительной
    *
    * Возвращает ссылку на файл для дальнейшей загрузки с сервера
    *
    * FileNotFound - файл не найден
    * */
    URL GenerateDownloadUrl (1: FileId file_id, 2: Timestamp expires_at)
        throws (1: FileNotFound ex1)

}
