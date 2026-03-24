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
// DEPRECATED: используется только legacy multipart flow, где сервис проксирует data plane вместо orchestration над S3
typedef base.ID PartID
// дополнительная информация о файле
typedef map<string, msgpack.Value> Metadata
// обязательные HTTP-заголовки для прямой загрузки части в object storage
typedef map<string, string> RequiredHeaders

exception FileNotFound {}

enum FileUploadStatus {
    pending_upload = 1
    uploaded = 2
    aborted = 3
}

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

struct PresignedMultipartUpload {
    // id файла
    1: required FileDataID file_data_id
    // id передачи файла по частям
    2: required MultipartUploadID multipart_upload_id
    // дата создания multipart-загрузки
    3: required Timestamp created_at
    // дополнительная информация о файле
    4: required Metadata metadata
    // текущий статус загрузки файла
    5: required FileUploadStatus upload_status
    // имя файла
    6: optional FileName file_name
    // прямая ссылка на объект в object storage, доступна только после успешного завершения загрузки
    7: optional URL file_url
}

struct PresignMultipartUploadPartRequest {
    // id файла
    1: required FileDataID file_data_id
    // id передачи файла по частям
    2: required MultipartUploadID multipart_upload_id
    // номер передаваемой части файла
    3: required i32 sequence_part
    // ожидаемый размер части файла в байтах
    4: optional i64 content_length
    // ожидаемое значение Content-MD5 для части файла
    5: optional string content_md5
    // ожидаемое значение x-amz-checksum-sha256 для части файла
    6: optional string checksum_sha256
}

struct PresignMultipartUploadPartResult {
    // номер передаваемой части файла
    1: required i32 sequence_part
    // ссылка на загрузку части файла напрямую в object storage
    2: required URL upload_url
    // время жизни presigned-ссылки на загрузку части файла
    3: required Timestamp expires_at
    // обязательные HTTP-заголовки, которые клиент должен передать при загрузке части файла
    4: required RequiredHeaders required_headers
}

struct CompletedPresignedMultipart {
    // ETag загруженной части файла
    1: required string etag
    // номер переданной части файла
    2: required i32 sequence_part
}

struct CompletePresignedMultipartUploadRequest {
    // id файла
    1: required FileDataID file_data_id
    // id передачи файла по частям
    2: required MultipartUploadID multipart_upload_id
    // список ETag загруженных частей файла
    3: required list<CompletedPresignedMultipart> completed_parts
}

struct AbortMultipartUploadRequest {
    // id файла
    1: required FileDataID file_data_id
    // id передачи файла по частям
    2: required MultipartUploadID multipart_upload_id
}

struct CompletePresignedMultipartUploadResult {
    // id файла
    1: required FileDataID file_data_id
    // id передачи файла по частям
    2: required MultipartUploadID multipart_upload_id
    // прямая ссылка на загруженный объект в object storage
    3: required URL file_url
    // текущий статус загрузки файла
    4: required FileUploadStatus upload_status
}

/*
* DEPRECATED: структура относится к legacy multipart flow.
* На текущем этапе этот flow не вписывается в целевую концепцию orchestration над S3,
* потому что сервис принимает и проксирует содержимое частей как data plane.
* */
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

/*
* DEPRECATED: структура относится к legacy multipart flow.
* На текущем этапе этот flow не вписывается в целевую концепцию orchestration над S3,
* потому что сервис принимает и проксирует содержимое частей как data plane.
* */
struct UploadMultipartResult {
    // id части файла
    1: required PartID part_id
    // номер переданной части файла
    2: required i32 sequence_part
}

/*
* DEPRECATED: структура относится к legacy multipart flow.
* На текущем этапе этот flow не вписывается в целевую концепцию orchestration над S3,
* потому что сервис принимает и проксирует содержимое частей как data plane.
* */
struct CompletedMultipart {
    // id части файла
    1: required PartID part_id
    // номер переданной части файла
    2: required i32 sequence_part
}

/*
* DEPRECATED: структура относится к legacy multipart flow.
* На текущем этапе этот flow не вписывается в целевую концепцию orchestration над S3,
* потому что сервис принимает и проксирует содержимое частей как data plane.
* */
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
    *
    * DEPRECATED: этот multipart flow не вписывается в целевую концепцию orchestration над S3,
    * потому что сервис участвует в data plane и проксирует байты через себя.
    * */
    CreateMultipartUploadResult CreateMultipartUpload (1: Metadata metadata) ( deprecated )

    /*
    * Загрузка части файла на сервер
    * upload_multipart_request_data - данные части файла: идентификатор файла, идентификатор частичной загрузки, ее соджержимое,
    * размер содержимого.
    *
    * Возвращает данные для идентификации части в загружаемом файле
    *
    * DEPRECATED: этот multipart flow не вписывается в целевую концепцию orchestration над S3,
    * потому что сервис участвует в data plane и проксирует байты через себя.
    * */
    UploadMultipartResult UploadMultipart (1: UploadMultipartRequestData upload_multipart_request_data) ( deprecated )

    /*
    * Завершение загрузки файла по частям и генерация ссылки на файл
    * complete_multipart_upload_request - данные о загруженных частях файла: идентификатор файла, идентификатор частичной загрузки
    * и список метаинформации о переданных частях файла
    *
    * Возвращает ссылку на файл
    *
    * DEPRECATED: этот multipart flow не вписывается в целевую концепцию orchestration над S3,
    * потому что сервис участвует в data plane и проксирует байты через себя.
    * */
    CompleteMultipartUploadResult CompleteMultipartUpload (1: CompleteMultipartUploadRequest complete_multipart_upload_request)
        ( deprecated )

}

/*
* Сервис для presigned multipart-загрузки файлов напрямую в object storage.
* */
service FileStoragePresignedMultipart {

    /*
    * Создать новую multipart-загрузку файла
    * metadata - данные о файле, которые сохраняются как метаданные при создании нового файла
    *
    * Возвращает идентификатор multipart-загрузки файла
    * */
    PresignedMultipartUpload CreateMultipartUpload (1: Metadata metadata)

    /*
    * Получить текущее состояние multipart-загрузки файла
    * file_data_id - id файла
    *
    * Возвращает данные multipart-загрузки файла
    *
    * FileNotFound - multipart-загрузка не найдена
    * */
    PresignedMultipartUpload GetMultipartUpload (1: FileDataID file_data_id)
        throws (1: FileNotFound ex1)

    /*
    * Сгенерировать ссылку для загрузки части файла напрямую в object storage
    * presign_multipart_upload_part_request - данные для генерации ссылки: идентификатор файла,
    * идентификатор multipart-загрузки и номер части.
    *
    * Возвращает ссылку для дальнейшей выгрузки части файла напрямую в object storage
    * */
    PresignMultipartUploadPartResult PresignMultipartUploadPart (
        1: PresignMultipartUploadPartRequest presign_multipart_upload_part_request
    )

    /*
    * Завершение multipart-загрузки файла и генерация ссылки на файл
    * complete_presigned_multipart_upload_request - данные о загруженных частях файла: идентификатор файла,
    * идентификатор multipart-загрузки и список метаинформации о переданных частях файла
    *
    * Возвращает ссылку на файл
    * */
    CompletePresignedMultipartUploadResult CompleteMultipartUpload (
        1: CompletePresignedMultipartUploadRequest complete_presigned_multipart_upload_request
    )

    /*
    * Прервать multipart-загрузку файла
    * abort_multipart_upload_request - данные multipart-загрузки: идентификатор файла и идентификатор multipart-загрузки
    * */
    void AbortMultipartUpload (1: AbortMultipartUploadRequest abort_multipart_upload_request)

}
