Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 219356B0078
	for <linux-mm@kvack.org>; Wed,  8 May 2013 19:39:10 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 6/6] add documentation about reclaim knob on proc.txt
Date: Thu,  9 May 2013 08:39:02 +0900
Message-Id: <1368056342-30836-7-git-send-email-minchan@kernel.org>
In-Reply-To: <1368056342-30836-1-git-send-email-minchan@kernel.org>
References: <1368056342-30836-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Namhyung Kim <namhyung@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

This patch adds stuff about new reclaim field in proc.txt

Acked-by: Rob Landley <rob@landley.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/filesystems/proc.txt | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 488c094..ee4cef1 100644
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
@@ -489,6 +490,25 @@ To clear the soft-dirty bit
 
 Any other value written to /proc/PID/clear_refs will have no effect.
 
+The file /proc/PID/reclaim is used to reclaim pages in this process.
+To reclaim file-backed pages,
+    > echo file > /proc/PID/reclaim
+
+To reclaim anonymous pages,
+    > echo anon > /proc/PID/reclaim
+
+To reclaim all pages,
+    > echo all > /proc/PID/reclaim
+
+Also, you can specify address range of process so part of address space
+will be reclaimed. The format is following as
+    > echo addr size-byte > /proc/PID/reclaim
+
+NOTE: addr should be page-aligned.
+
+Below is example which try to reclaim 2M from 0x100000.
+    > echo 0x100000 2M > /proc/PID/reclaim
+
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
 using /proc/kpageflags and number of times a page is mapped using
 /proc/kpagecount. For detailed explanation, see Documentation/vm/pagemap.txt.
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
