include "base.thrift"
include "msgpack.thrift"

namespace java com.rbkmoney.file.storage
namespace erlang file_storage

// время
typedef base.Timestamp Timestamp
// id файла
typedef base.ID FileDataId
// имя файла
typedef string FileName
// ссылка на файл
typedef string URL
// дополнительная информация о файле
typedef map<string, msgpack.Value> Metadata

exception FileNotFound {}

struct FileData {
    // id файла
    1: required FileDataId file_data_id
    // имя файла
    3: required FileName file_name
    // дата загрузки файла
    4: required Timestamp created_at
    // дополнительная информация о файле
    5: required Metadata metadata
}

struct NewFileResult {
    // id файла
    1: required FileDataId file_data_id
    // ссылка на файл для дальнейшей выгрузки на сервер
    2: required URL upload_url
}

/*
* Сервис для загрузки и выгрузки файлов
* */
service FileStorage {

    /*
    * Создать новый файл и сгенерировать ссылку для выгрузки файла на сервер
    * metadata - данные о файле, которые сохраняются как метаданные при создании нового файла
    * expires_at - время жизни ссылки и файла, от создания до выгрузки файла на сервер
    *
    * Возвращает данные о файле, необходимые для выгрузки на сервер
    * */
    NewFileResult CreateNewFile (1: Metadata metadata, 2: Timestamp expires_at)

    /*
    * Сгенерировать ссылку на файл для загрузки с сервера
    * file_data_id - id файла
    * expires_at - время до которого ссылка будет считаться действительной
    *
    * Возвращает ссылку на файл для дальнейшей загрузки с сервера
    *
    * FileNotFound - файл не найден
    * */
    URL GenerateDownloadUrl (1: FileDataId file_data_id, 2: Timestamp expires_at)
        throws (1: FileNotFound ex1)

    /*
    * Получить данные о файле
    * file_data_id - id файла
    *
    * Возвращает данные о файле, которые хранятся как метаданные файла
    *
    * FileNotFound - файл не найден
    * */
    FileData GetFileData (1: FileDataId file_data_id)
        throws (1: FileNotFound ex1)

}
