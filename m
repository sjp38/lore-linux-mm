Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 270BD6B03A1
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:35:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b84so34470627wmh.0
        for <linux-mm@kvack.org>; Tue, 16 May 2017 03:35:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r186si13660422wme.22.2017.05.16.03.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 03:35:29 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4GATBjd009463
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:35:27 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afxgakwv8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 06:35:27 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 16 May 2017 11:35:24 +0100
From: "Mike Rapoport" <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd: drop dead code
Date: Tue, 16 May 2017 13:35:17 +0300
Message-Id: <1494930917-3134-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Calculation of start end end in __wake_userfault function are not used and
can be removed.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f7555fc..1446e9d 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1101,11 +1101,6 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 static void __wake_userfault(struct userfaultfd_ctx *ctx,
 			     struct userfaultfd_wake_range *range)
 {
-	unsigned long start, end;
-
-	start = range->start;
-	end = range->start + range->len;
-
 	spin_lock(&ctx->fault_pending_wqh.lock);
 	/* wake all in the range and autoremove */
 	if (waitqueue_active(&ctx->fault_pending_wqh))
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
