Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 69B146B0038
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 04:45:33 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 6/6] add documentation on proc.txt
Date: Mon, 22 Apr 2013 17:45:06 +0900
Message-Id: <1366620306-30940-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1366620306-30940-1-git-send-email-minchan@kernel.org>
References: <1366620306-30940-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Rob Landley <rob@landley.net>

This patch adds documentation about new reclaim field in proc.txt

Cc: Rob Landley <rob@landley.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/filesystems/proc.txt | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 488c094..c1f5ee4 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -136,6 +136,7 @@ Table 1-1: Process specific entries in /proc
  maps		Memory maps to executables and library files	(2.4)
  mem		Memory held by this process
  root		Link to the root directory of this process
+ reclaim	Reclaim pages in this process
  stat		Process status
  statm		Process memory status information
  status		Process status in human readable form
@@ -489,6 +490,29 @@ To clear the soft-dirty bit
 
 Any other value written to /proc/PID/clear_refs will have no effect.
 
+The /proc/PID/reclaim is used to reclaim pages in this process.
+To reclaim file-backed pages,
+    > echo 1 > /proc/PID/reclaim
+
+To reclaim anonymous pages,
+    > echo 2 > /proc/PID/reclaim
+
+To reclaim both pages,
+    > echo 3 > /proc/PID/reclaim
+
+Also, you can specify address range of process so part of address space
+will be reclaimed. The format is following as
+    > echo 4 addr size > /proc/PID/reclaim
+
+To reclaim file-backed pages in address range,
+    > echo 4 $((1<<20) 4096 > /proc/PID/reclaim
+
+To reclaim anonymous pages in address range,
+    > echo 5 $((1<<20) 4096 > /proc/PID/reclaim
+
+To reclaim both pages in address range,
+    > echo 6 $((1<<20) 4096 > /proc/PID/reclaim
+
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
 using /proc/kpageflags and number of times a page is mapped using
 /proc/kpagecount. For detailed explanation, see Documentation/vm/pagemap.txt.
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
