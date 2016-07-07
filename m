Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFD836B0261
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 05:31:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so25029145pfa.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 02:31:59 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c10si3333874pan.75.2016.07.07.02.31.51
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 02:31:52 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RFC v2 09/13] cifs/file.c: Remove trailing white space
Date: Thu,  7 Jul 2016 18:29:59 +0900
Message-Id: <1467883803-29132-10-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, npiggin@kernel.dk, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Trailing white space is not accepted in kernel coding style. Remove
them.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 fs/cifs/file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index ff882ae..bcf9ead 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3851,7 +3851,7 @@ void cifs_oplock_break(struct work_struct *work)
  * In the non-cached mode (mount with cache=none), we shunt off direct read and write requests
  * so this method should never be called.
  *
- * Direct IO is not yet supported in the cached mode. 
+ * Direct IO is not yet supported in the cached mode.
  */
 static ssize_t
 cifs_direct_io(struct kiocb *iocb, struct iov_iter *iter, loff_t pos)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
