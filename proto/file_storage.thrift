include "base.thrift"
include "proto/msgpack.thrift"

namespace java dev.vality.file.storage
namespace erlang filestore.storage

// время
typedef base.Timestamp Timestamp
// id файла
typedef base.ID FileDataID
// id передачи файла по частям
typedef base.ID MultipartUploadID
// имя файла
typedef string FileName
// ссылка на файл
typedef string URL
// id переданной части файла
typedef base.ID PartID
// дополнительная информация о файле
typedef map<string, msgpack.Value> Metadata

exception FileNotFound {}

struct FileData {
    // id файла
    1: required FileDataID file_data_id
    // имя файла
    3: required FileName file_name
    // дата загрузки файла
    4: required Timestamp created_at
    // дополнительная информация о файле
    5: required Metadata metadata
}

struct NewFileResult {
    // id файла
    1: required FileDataID file_data_id
    // ссылка на файл для дальнейшей выгрузки на сервер
    2: required URL upload_url
}

struct CreateMultipartUploadResult {
    // id файла
    1: required FileDataID file_data_id
    // id передачи файла по частям
    2: required MultipartUploadID multipart_upload_id
}

struct UploadMultipartRequestData {
    // id файла
    1: required FileDataID file_data_id
    // id передачи файла по частям
    2: required MultipartUploadID multipart_upload_id
    // номер передаваемой части файла
    3: required i32 sequence_part
    // содержимое части файла
    4: required binary content
    // размер части файла в байтах
    5: required i32 content_length
}

struct UploadMultipartResult {
    // id части файла
    1: required PartID part_id
    // номер переданной части файла
    2: required i32 part_number
}

struct CompletedMultipart {
    // id части файла
    1: required PartID part_id
    // номер переданной части файла
    2: required i32 sequence_part
}

struct CompleteMultipartUploadRequest {
    // id файла
    1: required FileDataID file_data_id
    // id передачи файла по частям
    2: required MultipartUploadID multipart_upload_id
    // список id переданных частей файла
    3: required list<CompletedMultipart> completed_parts
}

struct CompleteMultipartUploadResult {
    // ссылка на файл
    1: required URL upload_url
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
    URL GenerateDownloadUrl (1: FileDataID file_data_id, 2: Timestamp expires_at)
        throws (1: FileNotFound ex1)

    /*
    * Получить данные о файле
    * file_data_id - id файла
    *
    * Возвращает данные о файле, которые хранятся как метаданные файла
    *
    * FileNotFound - файл не найден
    * */
    FileData GetFileData (1: FileDataID file_data_id)
        throws (1: FileNotFound ex1)

    /*
    * Создать новую загрузку файла по частям
    * metadata - данные о файле, которые сохраняются как метаданные при создании нового файла
    *
    * Возвращает идентификатор частичной загрузки файла
    * */
    CreateMultipartUploadResult CreateMultipartUpload (1: Metadata metadata)

    /*
    * Загрузка части файла на сервер
    * upload_multipart_request_data - данные части файла: идентификатор файла, идентификатор частичной загрузки, ее соджержимое,
    * размер содержимого.
    *
    * Возвращает данные для идентификации части в загружаемом файле
    * */
    UploadMultipartResult UploadMultipart (1: UploadMultipartRequestData upload_multipart_request_data)

    /*
    * Завершение загрузки файла по частям и генерация ссылки на файл
    * complete_multipart_upload_request - данные о загруженных частях файла: идентификатор файла, идентификатор частичной загрузки
    * и список метаинформации о переданных частях файла
    *
    * Возвращает ссылку на файл
    * */
    CompleteMultipartUploadResult CompleteMultipartUpload (1: CompleteMultipartUploadRequest complete_multipart_upload_request)

}
