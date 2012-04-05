Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C75A26B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 12:48:33 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1033893yen.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2012 09:48:32 -0700 (PDT)
From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH 1/2] Documentation: mm: Add compact_node on Documentation/sysctl/vm.txt
Date: Fri,  6 Apr 2012 01:48:08 +0900
Message-Id: <1333644489-31466-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Masanari Iida <standby24x7@gmail.com>

The Documentation/sysctl/vm.txt does include "compact_memory",
but it doesn't include "compact_node".

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/sysctl/vm.txt |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 9c11d97..c94acad 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -20,6 +20,7 @@ Currently, these files are in /proc/sys/vm:
 
 - block_dump
 - compact_memory
+- compact_node
 - dirty_background_bytes
 - dirty_background_ratio
 - dirty_bytes
@@ -76,6 +77,13 @@ huge pages although processes will also directly compact memory as required.
 
 ==============================================================
 
+compact_node
+
+Available only when CONFIG_COMPACTION is set and also the system is NUMA
+architecture. When a node number is written to the file, the kernel fixing
+the fragmented pages on the specified NUMA node. 
+
+==============================================================
 dirty_background_bytes
 
 Contains the amount of dirty memory at which the pdflush background writeback
-- 
1.7.10.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
