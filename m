Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6CE36B0253
	for <linux-mm@kvack.org>; Sat, 15 Oct 2016 11:23:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o81so8584510wma.1
        for <linux-mm@kvack.org>; Sat, 15 Oct 2016 08:23:14 -0700 (PDT)
Received: from mail.osadl.at (mail.osadl.at. [92.243.35.153])
        by mx.google.com with ESMTP id rr15si30102890wjb.65.2016.10.15.08.23.13
        for <linux-mm@kvack.org>;
        Sat, 15 Oct 2016 08:23:13 -0700 (PDT)
From: Andreas Platschek <andreas.platschek@opentech.at>
Subject: [PATCH] kmemleak: fix reference to Documentation
Date: Sat, 15 Oct 2016 15:22:26 +0000
Message-Id: <1476544946-18804-1-git-send-email-andreas.platschek@opentech.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andreas Platschek <andreas.platschek@opentech.at>

Documentation/kmemleak.txt was moved to Documentation/dev-tools/kmemleak.rst,
this fixes the reference to the new location.

Signed-off-by: Andreas Platschek <andreas.platschek@opentech.at>
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index a5e453c..d00fae0 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -19,7 +19,7 @@
  *
  *
  * For more information on the algorithm and kmemleak usage, please see
- * Documentation/kmemleak.txt.
+ * Documentation/dev-tools/kmemleak.rst.
  *
  * Notes on locking
  * ----------------
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
