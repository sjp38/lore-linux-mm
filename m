Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E207D6B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 01:41:29 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z12so13946572qkb.12
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 22:41:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t2si3573404qke.63.2017.10.15.22.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Oct 2017 22:41:29 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9G5cthK097508
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 01:41:28 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dme8apcxb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 01:41:27 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 16 Oct 2017 06:41:25 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH] userfaultfd: use mmgrab instead of open-coded increment of mm_count
Date: Mon, 16 Oct 2017 08:41:18 +0300
Message-Id: <1508132478-7738-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm <linux-mm@kvack.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 fs/userfaultfd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ef4b48d1ea42..876b670f602e 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -662,7 +662,7 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 		ctx->features = octx->features;
 		ctx->released = false;
 		ctx->mm = vma->vm_mm;
-		atomic_inc(&ctx->mm->mm_count);
+		mmgrab(ctx->mm);
 
 		userfaultfd_ctx_get(octx);
 		fctx->orig = octx;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
