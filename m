From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: [PATCH v2] Fix a build error when BLOCK=n
Date: Thu, 18 Oct 2007 09:55:29 -0500
Message-Id: <1192719329-32066-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, jens.axboe@oracle.com
Cc: Emil Medve <Emilian.Medve@Freescale.com>
List-ID: <linux-mm.kvack.org>

This happens when we don't use/have any block devices and a NFS root filesystem
is used

mapping_cap_writeback_dirty() is defined in linux/backing-dev.h which used to be
provided in mm/filemap.c by linux/blkdev.h until commit
f5ff8422bbdd59f8c1f699df248e1b7a11073027

Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
---

This is against Linus' tree: d85714d81cc0408daddb68c10f7fd69eafe7c213

linux-2.6> scripts/checkpatch.pl 0001-Fix-a-build-error-when-BLOCK-n.patch 
Your patch has no obvious style problems and is ready for submission.

 mm/filemap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 79f24a9..61efe94 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -27,6 +27,7 @@
 #include <linux/writeback.h>
 #include <linux/pagevec.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
-- 
1.5.3.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
