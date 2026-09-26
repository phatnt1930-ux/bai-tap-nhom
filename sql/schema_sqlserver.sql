-- ============================================================
-- Nen tang Quan ly Cuoc thi Nhiep anh Phim tich hop AI
-- Script khoi tao co so du lieu tren SQL Server
-- 14 bang, tao theo thu tu phu thuoc khoa ngoai
-- ============================================================

IF DB_ID(N'FilmContestDB') IS NULL
    CREATE DATABASE FilmContestDB;
GO
USE FilmContestDB;
GO

-- 1. AppUser - Nguoi dung
CREATE TABLE AppUser (
    UserId        INT             IDENTITY(1,1) NOT NULL,
    Email         VARCHAR(255)    NOT NULL,
    PasswordHash  VARCHAR(255)    NOT NULL,
    FullName      NVARCHAR(150)   NOT NULL,
    Pseudonym     NVARCHAR(100)   NULL,
    DateOfBirth   DATE            NULL,
    IsLocked      BIT             NOT NULL DEFAULT 0,
    IsAdmin       BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_AppUser PRIMARY KEY (UserId),
    CONSTRAINT UQ_AppUser_Email UNIQUE (Email)
);
GO

-- 2. Contest - Cuoc thi
CREATE TABLE Contest (
    ContestId           INT             IDENTITY(1,1) NOT NULL,
    ContestName         NVARCHAR(200)   NOT NULL,
    OrganizerName       NVARCHAR(200)   NOT NULL,
    RegistrationOpenAt  DATE            NOT NULL,
    SubmissionDeadline  DATE            NOT NULL,
    JudgingDeadline     DATE            NOT NULL,
    AnnouncementDate    DATE            NULL,
    Status              VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_Contest PRIMARY KEY (ContestId),
    CONSTRAINT CK_Contest_0 CHECK (SubmissionDeadline > RegistrationOpenAt),
    CONSTRAINT CK_Contest_1 CHECK (JudgingDeadline > SubmissionDeadline),
    CONSTRAINT CK_Contest_2 CHECK (Status IN ('Draft','Open','Judging','Announced'))
);
GO

-- 3. ContestRole - Vai tro theo cuoc thi
CREATE TABLE ContestRole (
    ContestRoleId    INT           IDENTITY(1,1) NOT NULL,
    UserId           INT           NOT NULL,
    ContestId        INT           NOT NULL,
    RoleType         VARCHAR(20)   NOT NULL,
    RulesAcceptedAt  DATETIME      NULL,
    CONSTRAINT PK_ContestRole PRIMARY KEY (ContestRoleId),
    CONSTRAINT UQ_ContestRole_0 UNIQUE (UserId, ContestId, RoleType),
    CONSTRAINT CK_ContestRole_1 CHECK (RoleType IN ('Organizer','Judge','Contestant')),
    CONSTRAINT FK_ContestRole_UserId FOREIGN KEY (UserId) REFERENCES AppUser (UserId) ON DELETE CASCADE,
    CONSTRAINT FK_ContestRole_ContestId FOREIGN KEY (ContestId) REFERENCES Contest (ContestId) ON DELETE CASCADE
);
GO

-- 4. Category - Hang muc
CREATE TABLE Category (
    CategoryId         INT             IDENTITY(1,1) NOT NULL,
    ContestId          INT             NOT NULL,
    CategoryName       NVARCHAR(120)   NOT NULL,
    EntryFormat        VARCHAR(10)     NOT NULL,
    MinPhotos          INT             NOT NULL,
    MaxPhotos          INT             NOT NULL,
    MaxEntriesPerUser  INT             NOT NULL,
    CONSTRAINT PK_Category PRIMARY KEY (CategoryId),
    CONSTRAINT CK_Category_0 CHECK (EntryFormat IN ('Single','Series')),
    CONSTRAINT CK_Category_1 CHECK (MinPhotos >= 1 AND MaxPhotos >= MinPhotos),
    CONSTRAINT FK_Category_ContestId FOREIGN KEY (ContestId) REFERENCES Contest (ContestId) ON DELETE CASCADE
);
GO

-- 5. Criterion - Tieu chi cham
CREATE TABLE Criterion (
    CriterionId    INT             IDENTITY(1,1) NOT NULL,
    ContestId      INT             NOT NULL,
    CriterionName  NVARCHAR(120)   NOT NULL,
    Weight         DECIMAL(5,2)    NOT NULL,
    MaxScore       DECIMAL(5,2)    NOT NULL,
    CONSTRAINT PK_Criterion PRIMARY KEY (CriterionId),
    CONSTRAINT CK_Criterion_0 CHECK (Weight > 0 AND MaxScore > 0),
    CONSTRAINT FK_Criterion_ContestId FOREIGN KEY (ContestId) REFERENCES Contest (ContestId) ON DELETE CASCADE
);
GO

-- 6. FilmStock - Loai phim
CREATE TABLE FilmStock (
    FilmStockId      INT             IDENTITY(1,1) NOT NULL,
    StockName        NVARCHAR(120)   NOT NULL,
    Manufacturer     NVARCHAR(80)    NOT NULL,
    FilmType         VARCHAR(20)     NOT NULL,
    BoxSpeed         INT             NOT NULL,
    StandardProcess  VARCHAR(20)     NOT NULL,
    IsVerified       BIT             NOT NULL DEFAULT 0,
    CONSTRAINT PK_FilmStock PRIMARY KEY (FilmStockId),
    CONSTRAINT UQ_FilmStock_0 UNIQUE (Manufacturer, StockName),
    CONSTRAINT CK_FilmStock_1 CHECK (FilmType IN ('ColorNegative','Slide','BlackWhite')),
    CONSTRAINT CK_FilmStock_2 CHECK (BoxSpeed > 0)
);
GO

-- 7. FilmRoll - Cuon phim
CREATE TABLE FilmRoll (
    FilmRollId     INT             IDENTITY(1,1) NOT NULL,
    OwnerUserId    INT             NOT NULL,
    FilmStockId    INT             NOT NULL,
    FilmFormat     VARCHAR(20)     NOT NULL,
    CameraModel    NVARCHAR(120)   NOT NULL,
    ExposureIndex  INT             NOT NULL,
    PushPullStops  SMALLINT        NOT NULL DEFAULT 0,
    DevelopedBy    VARCHAR(10)     NOT NULL,
    LabName        NVARCHAR(150)   NULL,
    ActualProcess  VARCHAR(20)     NOT NULL,
    DevelopedOn    DATE            NULL,
    ProofImageUrl  VARCHAR(500)    NULL,
    ProofStatus    VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_FilmRoll PRIMARY KEY (FilmRollId),
    CONSTRAINT CK_FilmRoll_0 CHECK (DevelopedBy IN ('Lab','Self')),
    CONSTRAINT CK_FilmRoll_1 CHECK (DevelopedBy = 'Self' OR LabName IS NOT NULL),
    CONSTRAINT CK_FilmRoll_2 CHECK (ExposureIndex > 0 AND PushPullStops BETWEEN -3 AND 3),
    CONSTRAINT CK_FilmRoll_3 CHECK (ProofStatus IN ('Pending','Verified','Rejected')),
    CONSTRAINT FK_FilmRoll_OwnerUserId FOREIGN KEY (OwnerUserId) REFERENCES AppUser (UserId),
    CONSTRAINT FK_FilmRoll_FilmStockId FOREIGN KEY (FilmStockId) REFERENCES FilmStock (FilmStockId)
);
GO

-- 8. Frame - Khung hinh
CREATE TABLE Frame (
    FilmRollId    INT             NOT NULL,
    FrameNo       VARCHAR(5)      NOT NULL,
    ShotOn        DATE            NULL,
    ShotLocation  NVARCHAR(200)   NULL,
    LensNote      NVARCHAR(120)   NULL,
    CONSTRAINT PK_Frame PRIMARY KEY (FilmRollId, FrameNo),
    CONSTRAINT FK_Frame_FilmRollId FOREIGN KEY (FilmRollId) REFERENCES FilmRoll (FilmRollId) ON DELETE CASCADE
);
GO

-- 9. Entry - Bai du thi
CREATE TABLE Entry (
    EntryId         INT             IDENTITY(1,1) NOT NULL,
    CategoryId      INT             NOT NULL,
    AuthorUserId    INT             NOT NULL,
    EntryCode       VARCHAR(20)     NOT NULL,
    Title           NVARCHAR(200)   NOT NULL,
    Status          VARCHAR(20)     NOT NULL,
    SubmittedAt     DATETIME        NULL,
    RejectReason    NVARCHAR(500)   NULL,
    FinalScore      DECIMAL(6,3)    NULL,
    RankInCategory  INT             NULL,
    PrizeName       NVARCHAR(120)   NULL,
    FinalizedAt     DATETIME        NULL,
    CONSTRAINT PK_Entry PRIMARY KEY (EntryId),
    CONSTRAINT UQ_Entry_EntryCode UNIQUE (EntryCode),
    CONSTRAINT CK_Entry_0 CHECK (Status IN ('Draft','Submitted','NeedsInfo','Accepted','Awarded','Rejected','Withdrawn')),
    CONSTRAINT CK_Entry_1 CHECK (Status <> 'Rejected' OR RejectReason IS NOT NULL),
    CONSTRAINT FK_Entry_CategoryId FOREIGN KEY (CategoryId) REFERENCES Category (CategoryId),
    CONSTRAINT FK_Entry_AuthorUserId FOREIGN KEY (AuthorUserId) REFERENCES AppUser (UserId)
);
GO

-- 10. EntryPhoto - Anh du thi
CREATE TABLE EntryPhoto (
    EntryPhotoId    INT             IDENTITY(1,1) NOT NULL,
    EntryId         INT             NOT NULL,
    FilmRollId      INT             NOT NULL,
    FrameNo         VARCHAR(5)      NOT NULL,
    SequenceNo      INT             NOT NULL,
    ScanMethod      VARCHAR(30)     NOT NULL,
    ScannerModel    NVARCHAR(120)   NULL,
    EditLevel       VARCHAR(20)     NOT NULL,
    FileUrl         VARCHAR(500)    NOT NULL,
    PerceptualHash  BIGINT          NULL,
    CONSTRAINT PK_EntryPhoto PRIMARY KEY (EntryPhotoId),
    CONSTRAINT UQ_EntryPhoto_0 UNIQUE (EntryId, SequenceNo),
    CONSTRAINT CK_EntryPhoto_2 CHECK (EditLevel IN ('None','BasicOnly')),
    CONSTRAINT FK_EntryPhoto_EntryId FOREIGN KEY (EntryId) REFERENCES Entry (EntryId) ON DELETE CASCADE,
    CONSTRAINT FK_EntryPhoto_FilmRollId_FrameNo FOREIGN KEY (FilmRollId, FrameNo) REFERENCES Frame (FilmRollId, FrameNo)
);
GO

-- 11. ScoreSheet - Phieu cham
CREATE TABLE ScoreSheet (
    ScoreSheetId  INT              IDENTITY(1,1) NOT NULL,
    EntryId       INT              NOT NULL,
    JudgeUserId   INT              NOT NULL,
    Status        VARCHAR(10)      NOT NULL,
    Comment       NVARCHAR(1000)   NULL,
    LockedAt      DATETIME         NULL,
    CONSTRAINT PK_ScoreSheet PRIMARY KEY (ScoreSheetId),
    CONSTRAINT UQ_ScoreSheet_0 UNIQUE (EntryId, JudgeUserId),
    CONSTRAINT CK_ScoreSheet_1 CHECK (Status IN ('Draft','Locked')),
    CONSTRAINT CK_ScoreSheet_2 CHECK (Status = 'Draft' OR LockedAt IS NOT NULL),
    CONSTRAINT FK_ScoreSheet_EntryId FOREIGN KEY (EntryId) REFERENCES Entry (EntryId) ON DELETE CASCADE,
    CONSTRAINT FK_ScoreSheet_JudgeUserId FOREIGN KEY (JudgeUserId) REFERENCES AppUser (UserId)
);
GO

-- 12. ScoreDetail - Diem theo tieu chi
CREATE TABLE ScoreDetail (
    ScoreSheetId  INT            NOT NULL,
    CriterionId   INT            NOT NULL,
    Score         DECIMAL(5,2)   NOT NULL,
    CONSTRAINT PK_ScoreDetail PRIMARY KEY (ScoreSheetId, CriterionId),
    CONSTRAINT CK_ScoreDetail_0 CHECK (Score >= 0),
    CONSTRAINT FK_ScoreDetail_ScoreSheetId FOREIGN KEY (ScoreSheetId) REFERENCES ScoreSheet (ScoreSheetId) ON DELETE CASCADE,
    CONSTRAINT FK_ScoreDetail_CriterionId FOREIGN KEY (CriterionId) REFERENCES Criterion (CriterionId)
);
GO

-- 13. AiAnalysis - Ket qua phan tich
CREATE TABLE AiAnalysis (
    AnalysisId        INT            IDENTITY(1,1) NOT NULL,
    EntryPhotoId      INT            NOT NULL,
    ModelName         VARCHAR(120)   NOT NULL,
    ModelVersion      VARCHAR(40)    NOT NULL,
    AnalysisType      VARCHAR(20)    NOT NULL,
    Confidence        DECIMAL(5,4)   NOT NULL,
    Verdict           VARCHAR(30)    NOT NULL,
    AnalyzedAt        DATETIME       NOT NULL,
    ReviewVerdict     VARCHAR(30)    NULL,
    ReviewedByUserId  INT            NULL,
    CONSTRAINT PK_AiAnalysis PRIMARY KEY (AnalysisId),
    CONSTRAINT CK_AiAnalysis_0 CHECK (Confidence BETWEEN 0 AND 1),
    CONSTRAINT CK_AiAnalysis_1 CHECK (AnalysisType IN ('Duplicate','AiGenerated')),
    CONSTRAINT FK_AiAnalysis_EntryPhotoId FOREIGN KEY (EntryPhotoId) REFERENCES EntryPhoto (EntryPhotoId) ON DELETE CASCADE,
    CONSTRAINT FK_AiAnalysis_ReviewedByUserId FOREIGN KEY (ReviewedByUserId) REFERENCES AppUser (UserId) ON DELETE SET NULL
);
GO

-- 14. DuplicateMatch - Cap anh nghi trung
CREATE TABLE DuplicateMatch (
    MatchId       INT            IDENTITY(1,1) NOT NULL,
    PhotoAId      INT            NOT NULL,
    PhotoBId      INT            NOT NULL,
    Similarity    DECIMAL(5,4)   NOT NULL,
    DetectedAt    DATETIME       NOT NULL,
    ReviewStatus  VARCHAR(20)    NOT NULL,
    CONSTRAINT PK_DuplicateMatch PRIMARY KEY (MatchId),
    CONSTRAINT CK_DuplicateMatch_0 CHECK (PhotoAId < PhotoBId),
    CONSTRAINT UQ_DuplicateMatch_1 UNIQUE (PhotoAId, PhotoBId),
    CONSTRAINT CK_DuplicateMatch_2 CHECK (Similarity BETWEEN 0 AND 1),
    CONSTRAINT CK_DuplicateMatch_3 CHECK (ReviewStatus IN ('Pending','Confirmed','Dismissed')),
    CONSTRAINT FK_DuplicateMatch_PhotoAId FOREIGN KEY (PhotoAId) REFERENCES EntryPhoto (EntryPhotoId),
    CONSTRAINT FK_DuplicateMatch_PhotoBId FOREIGN KEY (PhotoBId) REFERENCES EntryPhoto (EntryPhotoId)
);
GO

-- ============================================================
-- Chi muc cho khoa ngoai (SQL Server khong tu tao)
-- Bo qua khoa ngoai da la cot dau cua PK, UNIQUE hoac chi muc ghep
-- ============================================================
CREATE INDEX IX_ContestRole_ContestId ON ContestRole (ContestId);
CREATE INDEX IX_Category_ContestId ON Category (ContestId);
CREATE INDEX IX_Criterion_ContestId ON Criterion (ContestId);
CREATE INDEX IX_FilmRoll_OwnerUserId ON FilmRoll (OwnerUserId);
CREATE INDEX IX_FilmRoll_FilmStockId ON FilmRoll (FilmStockId);
CREATE INDEX IX_Entry_AuthorUserId ON Entry (AuthorUserId);
CREATE INDEX IX_EntryPhoto_FilmRollId_FrameNo ON EntryPhoto (FilmRollId, FrameNo);
CREATE INDEX IX_ScoreSheet_JudgeUserId ON ScoreSheet (JudgeUserId);
CREATE INDEX IX_ScoreDetail_CriterionId ON ScoreDetail (CriterionId);
CREATE INDEX IX_AiAnalysis_EntryPhotoId ON AiAnalysis (EntryPhotoId);
CREATE INDEX IX_AiAnalysis_ReviewedByUserId ON AiAnalysis (ReviewedByUserId);
CREATE INDEX IX_DuplicateMatch_PhotoBId ON DuplicateMatch (PhotoBId);
GO

-- Chi muc phuc vu bao cao xep hang (NF-1)
CREATE INDEX IX_Entry_Category_Score ON Entry (CategoryId, FinalScore DESC) INCLUDE (EntryCode);
-- Chi muc phuc vu do anh trung
CREATE INDEX IX_EntryPhoto_PerceptualHash ON EntryPhoto (PerceptualHash);
GO
