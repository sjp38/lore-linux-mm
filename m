Received: by nf-out-0910.google.com with SMTP id h3so1654772nfh
        for <linux-mm@kvack.org>; Wed, 07 Nov 2007 01:23:22 -0800 (PST)
Message-ID: <47318406.9030409@gmail.com>
Date: Wed, 07 Nov 2007 10:23:18 +0100
From: Jiri Olsa <olsajiri@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: Removing duplicit #includes
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Removing duplicit #includes for mm/
Signed-off-by: Jiri Olsa <olsajiri@gmail.com> 
---
 mm/filemap.c  |    1 -
 mm/swapfile.c |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 188cf5f..0b360de 100644
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
diff --git a/mm/swapfile.c b/mm/swapfile.c
index f071648..83da158 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1153,7 +1153,6 @@ out:
 }
 
 #if 0  /* We don't need this yet */
-#include <linux/backing-dev.h>
 int page_queue_congested(struct page *page)
 {
        struct backing_dev_info *bdi;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
