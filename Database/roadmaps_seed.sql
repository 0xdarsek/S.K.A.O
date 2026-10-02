-- =========================================================
-- roadmaps_seed.sql
-- ADDITIVE seed data for Abdullah's Career Paths & Self-Assessment module.
--
-- This script does NOT change the schema. It only INSERTs the sample data
-- the Roadmaps pages need to display something:
--   * a roadmap for the Red Team Operator path (the base schema seeds none)
--   * video Resources so Detail.aspx has a multimedia element to embed
--   * one self-assessment Quiz (with questions) per career path
--
-- Run it ONCE, AFTER certpath_schema.sql, in a query window against SKAODB.
-- Every block is guarded with IF NOT EXISTS, so re-running it will not create
-- duplicates. Coordinate with Darsek before running it on a shared database.
-- =========================================================
USE SKAODB;
GO

-- ---------------------------------------------------------
-- 0) Banner images for each path + official websites for each cert
--    (UPDATEs are safe to re-run.)
-- ---------------------------------------------------------
UPDATE CareerPaths SET ImageUrl = N'~/Assets/img/pentest.png' WHERE PathName = 'Penetration Tester';
UPDATE CareerPaths SET ImageUrl = N'~/Assets/img/redteam.png' WHERE PathName = 'Red Team Operator';
UPDATE CareerPaths SET ImageUrl = N'~/Assets/img/soc.png'     WHERE PathName = 'SOC Analyst';
UPDATE CareerPaths SET ImageUrl = N'~/Assets/img/hunter.png'  WHERE PathName = 'Threat Hunter';

UPDATE Certifications SET Website = N'https://www.comptia.org/certifications/security'                               WHERE CertName = 'CompTIA Security+';
UPDATE Certifications SET Website = N'https://security.ine.com/certifications/ejpt-certification/'                   WHERE CertName = 'eJPT';
UPDATE Certifications SET Website = N'https://www.offsec.com/courses/pen-200/'                                      WHERE CertName = 'OSCP';
UPDATE Certifications SET Website = N'https://www.giac.org/certifications/certified-incident-handler-gcih/'         WHERE CertName = 'GCIH';
UPDATE Certifications SET Website = N'https://www.eccouncil.org/train-certify/certified-ethical-hacker-ceh/'        WHERE CertName = 'CEH';
UPDATE Certifications SET Website = N'https://www.giac.org/certifications/cyber-threat-intelligence-gcti/'          WHERE CertName = 'GCTI';
GO

-- ---------------------------------------------------------
-- 1) Red Team Operator path roadmap (PathID = 2)
--    CertIDs from the base seed: 1=Security+, 3=OSCP, 5=CEH
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM PathCertifications WHERE PathID = 2)
BEGIN
    INSERT INTO PathCertifications (PathID, CertID, StepOrder) VALUES
    (2, 1, 1),   -- Security+
    (2, 5, 2),   -- CEH
    (2, 3, 3);   -- OSCP
END
GO

-- ---------------------------------------------------------
-- 2) Video resources (multimedia for Detail.aspx)
--    NOTE: these are example YouTube embed URLs. Open each page after seeding
--    and confirm the video plays; swap the embed id for one you prefer if not.
--    Embed URL format required by the <iframe>:  https://www.youtube.com/embed/<VIDEO_ID>
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM Resources WHERE ResourceType = 'Video')
BEGIN
    INSERT INTO Resources (CertID, Title, ResourceType, Url) VALUES
    (1, 'CompTIA Security+ - What it covers', 'Video', 'https://www.youtube.com/embed/nu_bLkncimA'),
    (3, 'OSCP / Offensive Security overview', 'Video', 'https://www.youtube.com/embed/2TofunAI6fU'),
    (5, 'Certified Ethical Hacker (CEH) overview', 'Video', 'https://www.youtube.com/embed/3Kq1MIfTWCE');

    -- A couple of non-video resources too, for a fuller Resources table.
    INSERT INTO Resources (CertID, Title, ResourceType, Url) VALUES
    (1, 'CompTIA Security+ official page', 'Course', 'https://www.comptia.org/certifications/security'),
    (3, 'OffSec PEN-200 course page', 'Course', 'https://www.offsec.com/courses/pen-200/');
END
GO

-- ---------------------------------------------------------
-- 3) Self-assessment quizzes, one per path, 5 questions each
-- ---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM Quizzes)
BEGIN
    DECLARE @quizId INT;

    -- ===== Path 1: Penetration Tester =====
    INSERT INTO Quizzes (PathID, Title) VALUES (1, 'Penetration Tester Self-Assessment');
    SET @quizId = SCOPE_IDENTITY();
    INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption) VALUES
    (@quizId, 'Which certification is the most advanced, hands-on penetration testing certification on this path?', 'CompTIA Security+', 'eJPT', 'OSCP', 'CEH', 'C'),
    (@quizId, 'What is the main goal of a penetration test?', 'To install antivirus software', 'To find and exploit vulnerabilities before real attackers do', 'To write company policies', 'To back up data', 'B'),
    (@quizId, 'Which tool is most commonly used for network port scanning?', 'Nmap', 'Photoshop', 'Excel', 'Outlook', 'A'),
    (@quizId, 'Which phase comes first in a penetration test?', 'Exploitation', 'Reconnaissance', 'Reporting', 'Clean-up', 'B'),
    (@quizId, 'What does the "eJPT" certification focus on?', 'Cloud billing', 'Entry-level practical penetration testing', 'Graphic design', 'Project management', 'B');

    -- ===== Path 2: Red Team Operator =====
    INSERT INTO Quizzes (PathID, Title) VALUES (2, 'Red Team Operator Self-Assessment');
    SET @quizId = SCOPE_IDENTITY();
    INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption) VALUES
    (@quizId, 'What best describes a red team engagement?', 'Fixing printers', 'Simulating a real-world adversary to test defences', 'Writing marketing copy', 'Managing payroll', 'B'),
    (@quizId, 'Which term describes moving from one compromised host to another inside a network?', 'Lateral movement', 'Defragmenting', 'Load balancing', 'Caching', 'A'),
    (@quizId, 'What is "C2" short for in red teaming?', 'Command and Control', 'Copy and Cut', 'Cloud Computing', 'Code Cleanup', 'A'),
    (@quizId, 'Which activity is a red team most associated with?', 'Adversary emulation', 'Data entry', 'Help-desk ticketing', 'Cable management', 'A'),
    (@quizId, 'Which of these is a common goal of a red team operation?', 'Increase font sizes', 'Reach a defined objective (e.g. domain admin) without being detected', 'Reduce electricity use', 'Improve website SEO', 'B');

    -- ===== Path 3: SOC Analyst =====
    INSERT INTO Quizzes (PathID, Title) VALUES (3, 'SOC Analyst Self-Assessment');
    SET @quizId = SCOPE_IDENTITY();
    INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption) VALUES
    (@quizId, 'What does SOC stand for?', 'Security Operations Center', 'System On Chip', 'Service Order Confirmation', 'Standard Operating Cost', 'A'),
    (@quizId, 'What type of tool aggregates and correlates security logs?', 'SIEM', 'CMS', 'CRM', 'IDE', 'A'),
    (@quizId, 'A SOC analyst''s primary daily task is to...', 'Design logos', 'Monitor, detect and respond to security incidents', 'Manage HR records', 'Sell products', 'B'),
    (@quizId, 'Which certification on this path focuses on incident handling?', 'GCIH', 'Photoshop', 'PMP', 'CCNA', 'A'),
    (@quizId, 'What is a "false positive" in security monitoring?', 'A real attack that was missed', 'An alert that turns out to be harmless', 'A type of firewall', 'A backup schedule', 'B');

    -- ===== Path 4: Threat Hunter =====
    INSERT INTO Quizzes (PathID, Title) VALUES (4, 'Threat Hunter Self-Assessment');
    SET @quizId = SCOPE_IDENTITY();
    INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption) VALUES
    (@quizId, 'Threat hunting is best described as...', 'Waiting for alerts to fire', 'Proactively searching for hidden threats that evade automated detection', 'Buying new hardware', 'Writing invoices', 'B'),
    (@quizId, 'Which framework catalogues adversary tactics and techniques?', 'MITRE ATT&CK', 'HTML5', 'ISO 9001', 'Bootstrap', 'A'),
    (@quizId, 'A hypothesis-driven hunt starts with...', 'A guess about how an attacker might operate', 'A random reboot', 'A new logo', 'A price increase', 'A'),
    (@quizId, 'Which certification on this path targets cyber threat intelligence?', 'GCTI', 'A+', 'ITIL', 'CPA', 'A'),
    (@quizId, 'What data source is most useful for threat hunting?', 'Endpoint and network logs', 'Printer toner levels', 'Cafeteria menus', 'Parking records', 'A');
END
GO

PRINT 'roadmaps_seed.sql completed.';
GO
