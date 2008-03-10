Received: by ug-out-1314.google.com with SMTP id u40so4120764ugc.29
        for <linux-mm@kvack.org>; Sun, 09 Mar 2008 17:17:50 -0700 (PDT)
Date: Mon, 10 Mar 2008 01:12:08 +0100 (CET)
Subject: [PATCH] Do not include linux/backing-dev.h twice inside
 mm/filemap.c
Message-ID: <alpine.LNX.1.00.0803100106370.7691@dragon.funnycrock.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
From: Jesper Juhl <jesper.juhl@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux memory management list <linux-mm@kvack.org>, Trivial Patch Monkey <trivial@kernel.org>, Emil Medve <Emilian.Medve@Freescale.com>, Jesper Juhl <jesper.juhl@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Don't include linux/backing-dev.h twice in mm/filemap.c, it's pointless.


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 filemap.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 5c74b68..ab98557 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -28,7 +28,6 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/blkdev.h>
-#include <linux/backing-dev.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
