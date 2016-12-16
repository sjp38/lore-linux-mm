Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7646B0268
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:26 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id y124so92848046iof.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 139si2959212itj.34.2016.12.16.06.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:24 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 03/42] userfaultfd: convert BUG() to WARN_ON_ONCE()
Date: Fri, 16 Dec 2016 15:47:42 +0100
Message-Id: <20161216144821.5183-4-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Avoid BUG_ON()s and only WARN instead. This is just a cleanup, it
can't make any runtime difference. This BUG_ON has never triggered and
cannot trigger.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 6ec08a9..4edbd99 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -541,7 +541,8 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
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
