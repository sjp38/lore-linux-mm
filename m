Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 503C66B027C
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i34so24641066qkh.1
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q35si1900006qtc.150.2016.11.02.12.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:08 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 02/33] userfaultfd: correct comment about UFFD_FEATURE_PAGEFAULT_FLAG_WP
Date: Wed,  2 Nov 2016 20:33:34 +0100
Message-Id: <1478115245-32090-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

Minor comment correction.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 85959d8..501784e 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -162,7 +162,7 @@ static inline struct uffd_msg userfault_msg(unsigned long address,
 	msg.arg.pagefault.address = address;
 	if (flags & FAULT_FLAG_WRITE)
 		/*
-		 * If UFFD_FEATURE_PAGEFAULT_FLAG_WRITE was set in the
+		 * If UFFD_FEATURE_PAGEFAULT_FLAG_WP was set in the
 		 * uffdio_api.features and UFFD_PAGEFAULT_FLAG_WRITE
 		 * was not set in a UFFD_EVENT_PAGEFAULT, it means it
 		 * was a read fault, otherwise if set it means it's

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
