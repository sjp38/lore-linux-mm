Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4F752808E6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 10:08:21 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id j127so134190130qke.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 07:08:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 12si5823608qtm.252.2017.03.09.07.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 07:08:20 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1] userfaultfd: remove wrong comment from userfaultfd_ctx_get()
Date: Thu,  9 Mar 2017 16:08:17 +0100
Message-Id: <20170309150817.7510-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, david@redhat.com, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

It's a void function, so there is no return value;

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 fs/userfaultfd.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 9fd5e51..2bb1c72 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -138,8 +138,6 @@ static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
  * userfaultfd_ctx_get - Acquires a reference to the internal userfaultfd
  * context.
  * @ctx: [in] Pointer to the userfaultfd context.
- *
- * Returns: In case of success, returns not zero.
  */
 static void userfaultfd_ctx_get(struct userfaultfd_ctx *ctx)
 {
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
