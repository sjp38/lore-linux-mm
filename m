Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0F76B0276
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:34:09 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id p16so10706608qta.5
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:34:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w77si1938432qkb.46.2016.11.02.12.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:08 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 03/33] userfaultfd: convert BUG() to WARN_ON_ONCE()
Date: Wed,  2 Nov 2016 20:33:35 +0100
Message-Id: <1478115245-32090-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

Avoid BUG_ON()s and only WARN instead. This is just a cleanup, it
can't make any runtime difference. This BUG_ON has never triggered and
cannot trigger.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 501784e..5a1c3cf 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -539,7 +539,8 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 			ret = POLLIN;
 		return ret;
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
+		return POLLERR;
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
