Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 795326B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:25 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id l8so21260477iti.6
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a203si6185135ioa.6.2016.12.16.06.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:24 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 02/42] userfaultfd: correct comment about UFFD_FEATURE_PAGEFAULT_FLAG_WP
Date: Fri, 16 Dec 2016 15:47:41 +0100
Message-Id: <20161216144821.5183-3-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Minor comment correction.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index d96e2f3..6ec08a9 100644
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
