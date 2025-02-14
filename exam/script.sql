USE [BackendExamHub]
GO
/****** Object:  Table [dbo].[MyOffice_ACPD]    Script Date: 2025/1/23 下午 06:22:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MyOffice_ACPD](
	[ACPD_SID] [char](20) NOT NULL,
	[ACPD_Cname] [nvarchar](60) NULL,
	[ACPD_Ename] [nvarchar](40) NULL,
	[ACPD_Sname] [nvarchar](40) NULL,
	[ACPD_Email] [nvarchar](60) NULL,
	[ACPD_Status] [tinyint] NULL,
	[ACPD_Stop] [bit] NULL,
	[ACPD_StopMemo] [nvarchar](60) NULL,
	[ACPD_LoginID] [nvarchar](30) NULL,
	[ACPD_LoginPWD] [nvarchar](60) NULL,
	[ACPD_Memo] [nvarchar](600) NULL,
	[ACPD_NowDateTime] [datetime] NULL,
	[ACPD_NowID] [nvarchar](20) NULL,
	[ACPD_UPDDateTime] [datetime] NULL,
	[ACPD_UPDID] [nvarchar](20) NULL,
 CONSTRAINT [PK_MyOffice_ACPD] PRIMARY KEY CLUSTERED 
(
	[ACPD_SID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MyOffice_ExcuteionLog]    Script Date: 2025/1/23 下午 06:22:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MyOffice_ExcuteionLog](
	[DeLog_AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[DeLog_StoredPrograms] [nvarchar](120) NOT NULL,
	[DeLog_GroupID] [uniqueidentifier] NOT NULL,
	[DeLog_isCustomDebug] [bit] NOT NULL,
	[DeLog_ExecutionProgram] [nvarchar](120) NOT NULL,
	[DeLog_ExecutionInfo] [nvarchar](max) NULL,
	[DeLog_verifyNeeded] [bit] NULL,
	[DeLog_ExDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_MOTC_DataExchangeLog] PRIMARY KEY CLUSTERED 
(
	[DeLog_AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[MyOffice_ACPD] ADD  CONSTRAINT [DF_MyOffice_ACPD_acpd_status]  DEFAULT ((0)) FOR [ACPD_Status]
GO
ALTER TABLE [dbo].[MyOffice_ACPD] ADD  CONSTRAINT [DF_MyOffice_ACPD_acpd_stop]  DEFAULT ((0)) FOR [ACPD_Stop]
GO
ALTER TABLE [dbo].[MyOffice_ACPD] ADD  CONSTRAINT [DF_MyOffice_ACPD_acpd_nowdatetime]  DEFAULT (getdate()) FOR [ACPD_NowDateTime]
GO
ALTER TABLE [dbo].[MyOffice_ACPD] ADD  CONSTRAINT [DF_MyOffice_ACPD_acpd_upddatetime]  DEFAULT (getdate()) FOR [ACPD_UPDDateTime]
GO
ALTER TABLE [dbo].[MyOffice_ExcuteionLog] ADD  CONSTRAINT [DF_MOTC_DataExchangeLog_DeLog_isCustomDebug]  DEFAULT ((0)) FOR [DeLog_isCustomDebug]
GO
ALTER TABLE [dbo].[MyOffice_ExcuteionLog] ADD  CONSTRAINT [DF_MyOffice_ExcuteionLog_DeLog_verifyNeeded]  DEFAULT ((0)) FOR [DeLog_verifyNeeded]
GO
ALTER TABLE [dbo].[MyOffice_ExcuteionLog] ADD  CONSTRAINT [DF_MOTC_DataExchangeLog_DeLog_ExDateTime]  DEFAULT (getdate()) FOR [DeLog_ExDateTime]
GO
/****** Object:  StoredProcedure [dbo].[NEWSID]    Script Date: 2025/1/23 下午 06:22:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NEWSID]
(
    @TableName nvarchar(128),
    @ReturnSID nvarchar(20) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SIDRowName NVARCHAR(20);

    DECLARE 
        @currentYear int,
        @dayOfYear int,
        @secondOfDay int,
        @alphabets char(36),
        @firstDigit char(1),
        @secondDigit char(1),
        @prefix char(2),
        @dayCode char(3),
        @secondCode char(5),
        @sql nvarchar(MAX),
        @randomValue char(10),
        @ParmDefinition nvarchar(500);

    DECLARE @tempTable TABLE
    (
        SID CHAR(20)
    );

    SET @currentYear = YEAR(GETDATE()) - 2000;
    SET @dayOfYear = DATEPART(DAYOFYEAR, GETDATE());
    SET @secondOfDay = DATEPART(SECOND, GETDATE()) + (60 * DATEPART(MINUTE, GETDATE())) + (3600 * DATEPART(HOUR, GETDATE()));
    
    IF (@currentYear > 1295)
    BEGIN
        SET @currentYear = 1295;
    END;

    SET @alphabets = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    SET @firstDigit = SUBSTRING(@alphabets, (@currentYear / 36) % 36 + 1, 1);
    SET @secondDigit = SUBSTRING(@alphabets, @currentYear % 36 + 1, 1);
    SET @prefix = @firstDigit + @secondDigit;
    SET @dayCode = RIGHT('000' + CONVERT(VARCHAR, @dayOfYear), 3);
    SET @secondCode = RIGHT('00000' + CONVERT(VARCHAR, @secondOfDay), 5);

    -- 尋找 Table 的欄位
    SELECT 
        TOP 1 
        @SIDRowName = STUFF((
            SELECT ', ' + c.name 
            FROM sys.index_columns ic
            JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
            WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
            ORDER BY ic.key_ordinal
            FOR XML PATH('')
        ), 1, 2, '') 
    FROM sys.indexes i 
    WHERE i.object_id = OBJECT_ID(@TableName) AND i.index_id > 0; -- 排除堆

    -- 尋找預設的
    WHILE 1 = 1
    BEGIN
        SET @randomValue = RIGHT('0000000000' + CAST(ABS(CAST(CAST(NEWID() AS BINARY(5)) AS BIGINT)) % 10000000000 AS VARCHAR(10)), 10);
        SET @ReturnSID = @prefix + @dayCode + @secondCode + @randomValue;
        
        SET @sql = N'SELECT @SIDRowNameOUT = ' + QUOTENAME(@SIDRowName) + ' FROM ' + QUOTENAME(@TableName) + ' WHERE ' + QUOTENAME(@SIDRowName) + ' = @ReturnSIDIN';
        
        SET @ParmDefinition = N'@ReturnSIDIN nvarchar(20), @SIDRowNameOUT nvarchar(20) OUTPUT';

        DELETE FROM @tempTable;

        DECLARE @SIDRowNameOUT nvarchar(20);
        
        EXEC sp_executesql @sql, @ParmDefinition, 
            @ReturnSIDIN = @ReturnSID, 
            @SIDRowNameOUT = @SIDRowNameOUT OUTPUT;
        
        IF @SIDRowNameOUT IS NULL
            BREAK;
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_MyOffice_ACPD_CRUD]    Script Date: 2025/1/23 下午 06:22:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_MyOffice_ACPD_CRUD]
    @Action NVARCHAR(10),         -- 動作類型：'CREATE', 'READ', 'UPDATE', 'DELETE'
    @JsonInput NVARCHAR(MAX) = NULL, -- JSON 輸入，用於插入或更新數據
    @JsonOutput NVARCHAR(MAX) OUTPUT -- JSON 輸出，用於返回查詢結果
AS
BEGIN
    SET NOCOUNT ON;

    -- CREATE 操作
    IF @Action = 'CREATE'
    BEGIN
        INSERT INTO dbo.MyOffice_ACPD (
            ACPD_SID,
            ACPD_Cname,
            ACPD_Ename,
            ACPD_Sname,
            ACPD_Email,
            ACPD_Status,
            ACPD_Stop,
            ACPD_StopMemo,
            ACPD_LoginID,
            ACPD_LoginPWD,
            ACPD_Memo,
            ACPD_NowID
        )
        SELECT 
            JSON_VALUE(@JsonInput, '$.ACPD_SID'),
            JSON_VALUE(@JsonInput, '$.ACPD_Cname'),
            JSON_VALUE(@JsonInput, '$.ACPD_Ename'),
            JSON_VALUE(@JsonInput, '$.ACPD_Sname'),
            JSON_VALUE(@JsonInput, '$.ACPD_Email'),
            JSON_VALUE(@JsonInput, '$.ACPD_Status'),
            JSON_VALUE(@JsonInput, '$.ACPD_Stop'),
            JSON_VALUE(@JsonInput, '$.ACPD_StopMemo'),
            JSON_VALUE(@JsonInput, '$.ACPD_LoginID'),
            JSON_VALUE(@JsonInput, '$.ACPD_LoginPWD'),
            JSON_VALUE(@JsonInput, '$.ACPD_Memo'),
            JSON_VALUE(@JsonInput, '$.ACPD_NowID');

        SET @JsonOutput = JSON_QUERY('{"Result": "Record Created Successfully"}');
    END

    -- READ 操作
    ELSE IF @Action = 'READ'
    BEGIN
        SELECT 
            ACPD_SID,
            ACPD_Cname,
            ACPD_Ename,
            ACPD_Sname,
            ACPD_Email,
            ACPD_Status,
            ACPD_Stop,
            ACPD_StopMemo,
            ACPD_LoginID,
            ACPD_LoginPWD,
            ACPD_Memo,
            ACPD_NowDateTime,
            ACPD_NowID,
            ACPD_UPDDateTime,
            ACPD_UPDID
        FROM dbo.MyOffice_ACPD
        WHERE ACPD_SID = JSON_VALUE(@JsonInput, '$.ACPD_SID')  -- 根據 SID 查詢特定記錄
        FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER;

        SET @JsonOutput = (SELECT 
            ACPD_SID,
            ACPD_Cname,
            ACPD_Ename,
            ACPD_Sname,
            ACPD_Email,
            ACPD_Status,
            ACPD_Stop,
            ACPD_StopMemo,
            ACPD_LoginID,
            ACPD_LoginPWD,
            ACPD_Memo,
            ACPD_NowDateTime,
            ACPD_NowID,
            ACPD_UPDDateTime,
            ACPD_UPDID
        FROM dbo.MyOffice_ACPD
        WHERE ACPD_SID = JSON_VALUE(@JsonInput, '$.ACPD_SID')  -- 根據 SID 查詢特定記錄
        FOR JSON AUTO);
    END

    -- UPDATE 操作
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.MyOffice_ACPD
        SET 
            ACPD_Cname = JSON_VALUE(@JsonInput, '$.ACPD_Cname'),
            ACPD_Ename = JSON_VALUE(@JsonInput, '$.ACPD_Ename'),
            ACPD_Sname = JSON_VALUE(@JsonInput, '$.ACPD_Sname'),
            ACPD_Email = JSON_VALUE(@JsonInput, '$.ACPD_Email'),
            ACPD_Status = JSON_VALUE(@JsonInput, '$.ACPD_Status'),
            ACPD_Stop = JSON_VALUE(@JsonInput, '$.ACPD_Stop'),
            ACPD_StopMemo = JSON_VALUE(@JsonInput, '$.ACPD_StopMemo'),
            ACPD_LoginID = JSON_VALUE(@JsonInput, '$.ACPD_LoginID'),
            ACPD_LoginPWD = JSON_VALUE(@JsonInput, '$.ACPD_LoginPWD'),
            ACPD_Memo = JSON_VALUE(@JsonInput, '$.ACPD_Memo'),
            ACPD_UPDDateTime = GETDATE(),
            ACPD_UPDID = JSON_VALUE(@JsonInput, '$.ACPD_UPDID')
        WHERE 
           ACPD_SID = JSON_VALUE(@JsonInput, '$.ACPD_SID');

        SET @JsonOutput = JSON_QUERY('{"Result": "Record Updated Successfully"}');
    END

    -- DELETE 操作
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.MyOffice_ACPD
        WHERE 
           ACPD_SID = JSON_VALUE(@JsonInput, '$.ACPD_SID');

        SET @JsonOutput = JSON_QUERY('{"Result": "Record Deleted Successfully"}');
    END

    -- 無效操作
    ELSE
    BEGIN
        SET @JsonOutput = JSON_QUERY('{"Error": "Invalid Action"}');
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_MyOffice_ACPD_CRUD_WithLog]    Script Date: 2025/1/23 下午 06:22:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_MyOffice_ACPD_CRUD_WithLog]
    @Action NVARCHAR(10),         -- 動作類型：'CREATE', 'READ', 'UPDATE', 'DELETE'
    @JsonInput NVARCHAR(MAX) = NULL, -- JSON 輸入，用於插入或更新數據
    @JsonOutput NVARCHAR(MAX) OUTPUT, -- JSON 輸出，用於返回查詢結果
    @GroupID UNIQUEIDENTIFIER -- 用於記錄執行過程
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ReturnSID NVARCHAR(20);
    DECLARE @LogReturn NVARCHAR(MAX);
    DECLARE @StoredProcedureName NVARCHAR(120) = 'sp_MyOffice_ACPD_CRUD_WithLog';

    -- CREATE 操作
    IF @Action = 'CREATE'
    BEGIN
        -- 取得新 SID
        EXEC dbo.NEWSID 
            @TableName = 'MyOffice_ACPD',
            @ReturnSID = @ReturnSID OUTPUT;

        -- 插入數據
        INSERT INTO dbo.MyOffice_ACPD (
            ACPD_SID,
            ACPD_Cname,
            ACPD_Ename,
            ACPD_Sname,
            ACPD_Email,
            ACPD_Status,
            ACPD_Stop,
            ACPD_StopMemo,
            ACPD_LoginID,
            ACPD_LoginPWD,
            ACPD_Memo,
            ACPD_NowID
        )
        SELECT 
            @ReturnSID,
            JSON_VALUE(@JsonInput, '$.ACPD_Cname'),
            JSON_VALUE(@JsonInput, '$.ACPD_Ename'),
            JSON_VALUE(@JsonInput, '$.ACPD_Sname'),
            JSON_VALUE(@JsonInput, '$.ACPD_Email'),
            JSON_VALUE(@JsonInput, '$.ACPD_Status'),
            JSON_VALUE(@JsonInput, '$.ACPD_Stop'),
            JSON_VALUE(@JsonInput, '$.ACPD_StopMemo'),
            JSON_VALUE(@JsonInput, '$.ACPD_LoginID'),
            JSON_VALUE(@JsonInput, '$.ACPD_LoginPWD'),
            JSON_VALUE(@JsonInput, '$.ACPD_Memo'),
            JSON_VALUE(@JsonInput, '$.ACPD_NowID');

        SET @JsonOutput = JSON_QUERY('{"Result": "Record Created Successfully", "NewSID": "' + @ReturnSID + '"}');
    END

    -- READ 操作
    ELSE IF @Action = 'READ'
    BEGIN
        SET @JsonOutput = (
            SELECT 
                ACPD_SID,
                ACPD_Cname,
                ACPD_Ename,
                ACPD_Sname,
                ACPD_Email,
                ACPD_Status,
                ACPD_Stop,
                ACPD_StopMemo,
                ACPD_LoginID,
                ACPD_LoginPWD,
                ACPD_Memo,
                ACPD_NowDateTime,
                ACPD_NowID,
                ACPD_UPDDateTime,
                ACPD_UPDID
            FROM dbo.MyOffice_ACPD
            FOR JSON PATH, INCLUDE_NULL_VALUES
        );
    END

    -- UPDATE 操作
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE dbo.MyOffice_ACPD
        SET 
            ACPD_Cname = JSON_VALUE(@JsonInput, '$.ACPD_Cname'),
            ACPD_Ename = JSON_VALUE(@JsonInput, '$.ACPD_Ename'),
            ACPD_Sname = JSON_VALUE(@JsonInput, '$.ACPD_Sname'),
            ACPD_Email = JSON_VALUE(@JsonInput, '$.ACPD_Email'),
            ACPD_Status = JSON_VALUE(@JsonInput, '$.ACPD_Status'),
            ACPD_Stop = JSON_VALUE(@JsonInput, '$.ACPD_Stop'),
            ACPD_StopMemo = JSON_VALUE(@JsonInput, '$.ACPD_StopMemo'),
            ACPD_LoginID = JSON_VALUE(@JsonInput, '$.ACPD_LoginID'),
            ACPD_LoginPWD = JSON_VALUE(@JsonInput, '$.ACPD_LoginPWD'),
            ACPD_Memo = JSON_VALUE(@JsonInput, '$.ACPD_Memo'),
            ACPD_UPDDateTime = GETDATE(),
            ACPD_UPDID = JSON_VALUE(@JsonInput, '$.ACPD_UPDID')
        WHERE ACPD_SID = JSON_VALUE(@JsonInput, '$.ACPD_SID');

        SET @JsonOutput = JSON_QUERY('{"Result": "Record Updated Successfully"}');
    END

    -- DELETE 操作
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM dbo.MyOffice_ACPD
        WHERE ACPD_SID = JSON_VALUE(@JsonInput, '$.ACPD_SID');

        SET @JsonOutput = JSON_QUERY('{"Result": "Record Deleted Successfully"}');
    END

    -- 記錄執行過程
    EXEC dbo.usp_AddLog
        @_InBox_ReadID = 0,
        @_InBox_SPNAME = @StoredProcedureName,
        @_InBox_GroupID = @GroupID,
        @_InBox_ExProgram = @Action,
        @_InBox_ActionJSON = @JsonInput,
        @_OutBox_ReturnValues = @LogReturn OUTPUT;

    -- 附加記錄信息到輸出
    SET @JsonOutput = JSON_MODIFY(@JsonOutput, '$.LogInfo', @LogReturn);
END
GO
/****** Object:  StoredProcedure [dbo].[usp_AddLog]    Script Date: 2025/1/23 下午 06:22:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_AddLog]
(
    @_InBox_ReadID        tinyint,                -- 執行 Log 時是使用第幾版
    @_InBox_SPNAME       nvarchar(120),          -- 執行的預存程序名稱
    @_InBox_GroupID      uniqueidentifier,        -- 執行群組代碼
    @_InBox_ExProgram    nvarchar(40),           -- 執行的動作是什麼
    @_InBox_ActionJSON    nvarchar(Max),         -- 執行的過程是什麼
    @_OutBox_ReturnValues nvarchar(Max) OUTPUT    -- 回傳執行的項目
) 
AS
BEGIN
    SET NOCOUNT ON;

    -- ========================= 新增與維護注意事項 =====================
    -- 相關注解說明請寫在這裡，以免從 Visual Studio 轉至 SQL 說明內容沒有一起上去
    -- 如果要修改請以這檔案為主，並以 SSMS 19.0 版以上來修改以便有完整的編輯模式
    -- 編輯時請交由「專案人員」來進行相關的修正，修改前也請確定在 C# Class 內，
    -- 有那些程序有〔參考〕到並再加以確定修改後不會有任何影響，再行修正以下 TSQL 的語法，以免
    -- 你修改後，會使得其他程序也有引用到以下的資料而有所影響。
    -- ==========================================================================
    
    DECLARE @_StoredProgramsNAME nvarchar(100) = 'usp_AddLog'; -- 執行項目
    
    DECLARE @_ReturnTable TABLE 
    (
        [RT_Status]        bit,                     --執行結果
        [RT_ActionValues]  nvarchar(2000)           --回傳結果為何
    ); 
    
    --======= 執行行為與動作 ====================
    
    IF (@_InBox_ReadID = 0) 
    BEGIN
        INSERT INTO MyOffice_ExcuteionLog 
        (
            DeLog_StoredPrograms,
            DeLog_GroupID,
            DeLog_ExecutionProgram,
            DeLog_ExecutionInfo
        )
        VALUES
        (
            @_InBox_SPNAME,
            @_InBox_GroupID,
            @_InBox_ExProgram,
            @_InBox_ActionJSON
        );

        SET @_OutBox_ReturnValues =
        (
            SELECT TOP 100 
                DeLog_AutoID AS 'AutoID',
                DeLog_ExecutionProgram AS 'NAME',
                DeLog_ExecutionInfo AS 'Action',
                DeLog_ExDateTime AS 'DateTime'
            FROM MyOffice_ExcuteionLog WITH(NOLOCK)
            WHERE DeLog_GroupID = @_InBox_GroupID
            ORDER BY DeLog_AutoID 
            FOR JSON PATH, ROOT('ProgramLog'), INCLUDE_NULL_VALUES
        ); 

        RETURN;
    END;
END;
GO
