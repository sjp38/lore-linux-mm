Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 546FC6B02F2
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 23:07:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p81so14748971pfd.12
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 20:07:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z27si1308419pfj.235.2017.04.26.20.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Apr 2017 20:07:28 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3R33sNP013439
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 23:07:28 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a2xcm7fs2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 23:07:27 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 27 Apr 2017 13:07:25 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3R37EJo4063696
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 13:07:22 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3R36oIM012882
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 13:06:50 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/vmstat: Standardize file operations variable names
Date: Thu, 27 Apr 2017 08:36:32 +0530
Message-Id: <20170427030632.8588-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org

Standardized the file operation variable names related to all
four memory management /proc interface files. Also changed all
the symbol permissions (S_IRUGO) into octal permissions (0444)
as it got complains from checkpatch.pl script. This does not
create any functional change to the interface.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/vmstat.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5a4f5c5..43b6087 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1318,7 +1318,7 @@ static int fragmentation_open(struct inode *inode, struct file *file)
 	return seq_open(file, &fragmentation_op);
 }
 
-static const struct file_operations fragmentation_file_operations = {
+static const struct file_operations buddyinfo_file_operations = {
 	.open		= fragmentation_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
@@ -1337,7 +1337,7 @@ static int pagetypeinfo_open(struct inode *inode, struct file *file)
 	return seq_open(file, &pagetypeinfo_op);
 }
 
-static const struct file_operations pagetypeinfo_file_ops = {
+static const struct file_operations pagetypeinfo_file_operations = {
 	.open		= pagetypeinfo_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
@@ -1454,7 +1454,7 @@ static int zoneinfo_open(struct inode *inode, struct file *file)
 	return seq_open(file, &zoneinfo_op);
 }
 
-static const struct file_operations proc_zoneinfo_file_operations = {
+static const struct file_operations zoneinfo_file_operations = {
 	.open		= zoneinfo_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
@@ -1543,7 +1543,7 @@ static int vmstat_open(struct inode *inode, struct file *file)
 	return seq_open(file, &vmstat_op);
 }
 
-static const struct file_operations proc_vmstat_file_operations = {
+static const struct file_operations vmstat_file_operations = {
 	.open		= vmstat_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
@@ -1789,10 +1789,10 @@ void __init init_mm_internals(void)
 	start_shepherd_timer();
 #endif
 #ifdef CONFIG_PROC_FS
-	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
-	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
-	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
-	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
+	proc_create("buddyinfo", 0444, NULL, &buddyinfo_file_operations);
+	proc_create("pagetypeinfo", 0444, NULL, &pagetypeinfo_file_operations);
+	proc_create("vmstat", 0444, NULL, &vmstat_file_operations);
+	proc_create("zoneinfo", 0444, NULL, &zoneinfo_file_operations);
 #endif
 }
 
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
