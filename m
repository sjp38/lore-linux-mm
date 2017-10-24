Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6BA96B026D
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 05:39:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b85so18107290pfj.22
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 02:39:16 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n9si5207178pll.526.2017.10.24.02.39.00
        for <linux-mm@kvack.org>;
        Tue, 24 Oct 2017 02:39:01 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 7/8] genhd.h: Remove trailing white space
Date: Tue, 24 Oct 2017 18:38:08 +0900
Message-Id: <1508837889-16932-8-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
References: <1508837889-16932-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, axboe@kernel.dk
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tj@kernel.org, johannes.berg@intel.com, oleg@redhat.com, amir73il@gmail.com, david@fromorbit.com, darrick.wong@oracle.com, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, hch@infradead.org, idryomov@gmail.com, kernel-team@lge.com

Trailing white space is not accepted in kernel coding style. Remove
them.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/genhd.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/genhd.h b/include/linux/genhd.h
index ea652bf..6d85a75 100644
--- a/include/linux/genhd.h
+++ b/include/linux/genhd.h
@@ -3,7 +3,7 @@
 
 /*
  * 	genhd.h Copyright (C) 1992 Drew Eckhardt
- *	Generic hard disk header file by  
+ *	Generic hard disk header file by
  * 		Drew Eckhardt
  *
  *		<drew@colorado.edu>
@@ -471,7 +471,7 @@ struct bsd_disklabel {
 	__s16	d_type;			/* drive type */
 	__s16	d_subtype;		/* controller/d_type specific */
 	char	d_typename[16];		/* type name, e.g. "eagle" */
-	char	d_packname[16];			/* pack identifier */ 
+	char	d_packname[16];			/* pack identifier */
 	__u32	d_secsize;		/* # of bytes per sector */
 	__u32	d_nsectors;		/* # of data sectors per track */
 	__u32	d_ntracks;		/* # of tracks per cylinder */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
