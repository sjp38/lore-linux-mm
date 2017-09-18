Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 16DEC6B0033
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 12:28:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 6so1467434pgh.0
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 09:28:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c10sor3612503pgp.174.2017.09.18.09.28.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Sep 2017 09:28:09 -0700 (PDT)
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] idr: fix comment for idr_replace()
Date: Mon, 18 Sep 2017 09:26:42 -0700
Message-Id: <20170918162642.37511-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, Eric Biggers <ebiggers@google.com>

From: Eric Biggers <ebiggers@google.com>

idr_replace() returns the old value on success, not 0.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 lib/idr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/idr.c b/lib/idr.c
index f9adf4805fd7..edd9b2be1651 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -146,8 +146,8 @@ EXPORT_SYMBOL(idr_get_next_ext);
  * idr_alloc() and idr_remove() (as long as the ID being removed is not
  * the one being replaced!).
  *
- * Returns: 0 on success.  %-ENOENT indicates that @id was not found.
- * %-EINVAL indicates that @id or @ptr were not valid.
+ * Returns: the old value on success.  %-ENOENT indicates that @id was not
+ * found.  %-EINVAL indicates that @id or @ptr were not valid.
  */
 void *idr_replace(struct idr *idr, void *ptr, int id)
 {
-- 
2.14.1.690.gbb1197296e-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
