Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 243946B004D
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 12:48:36 -0400 (EDT)
Received: by yhr47 with SMTP id 47so1041692yhr.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 09:48:35 -0700 (PDT)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 2/2] Documentation: mm: Fix path to extfrag_index in vm.txt
Date: Fri,  6 Apr 2012 01:48:09 +0900
Message-Id: <1333644489-31466-2-git-send-email-standby24x7@gmail.com>
In-Reply-To: <1333644489-31466-1-git-send-email-standby24x7@gmail.com>
References: <1333644489-31466-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Masanari Iida <standby24x7@gmail.com>

The path for extfrag_index has not been updated even after it moved
to under /sys. This patch fixed the path.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/sysctl/vm.txt |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index c94acad..9dd8555 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -166,11 +166,12 @@ user should run `sync' first.
 extfrag_threshold
 
 This parameter affects whether the kernel will compact memory or direct
-reclaim to satisfy a high-order allocation. /proc/extfrag_index shows what
-the fragmentation index for each order is in each zone in the system. Values
-tending towards 0 imply allocations would fail due to lack of memory,
-values towards 1000 imply failures are due to fragmentation and -1 implies
-that the allocation will succeed as long as watermarks are met.
+reclaim to satisfy a high-order allocation. 
+/sys/kernel/debug/extfrag/extfrag_index shows what the fragmentation index 
+for each order is in each zone in the system. Values tending towards 0 
+imply allocations would fail due to lack of memory, values towards 1000 
+imply failures are due to fragmentation and -1 implies that the allocation 
+will succeed as long as watermarks are met.
 
 The kernel will not compact memory in a zone if the
 fragmentation index is <= extfrag_threshold. The default value is 500.
-- 
1.7.10.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
