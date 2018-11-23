namespace java com.rbkmoney.file.storage
namespace erlang file_storage

// время
typedef string Timestamp
// id файла
typedef string FileId
// имя файла
typedef string FileName
// ссылка на файл
typedef string URL
// дополнительная информация о файле
typedef map<string, string> Metadata

exception FileNotFound {}

struct FileData {
    // id файла
    1: required FileId file_id
    // имя файла
    2: required FileName file_name
    // дата загрузки файла
    3: required Timestamp created_at
    // сигнатура
    4: required string md5
    // дополнительная информация о файле
    5: required Metadata metadata
}

struct NewFileResult {
    // ссылка на файл для дальнейшей выгрузки на сервер
    1: required URL upload_url
    // id файла
    2: required FileId file_id
}

/*
* Сервис для загрузки и выгрузки файлов
* */
service FileStorage {

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
    * Создать новый файл и сгенерировать ссылку для выгрузки файла на сервер
    * file_name - имя файла
    * metadata - данные о файле, которые сохраняются как метаданные при создании нового файла
    * expires_at - время жизни ссылки и файла, от создания до выгрузки файла на сервер
    *
    * Возвращает данные о файле, необходимые для выгрузки на сервер
    * */
    NewFileResult CreateNewFile (1: FileName file_name, 2: Metadata metadata, 3: Timestamp expires_at)

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
