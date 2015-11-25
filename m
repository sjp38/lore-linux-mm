Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3D58D6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 04:07:53 -0500 (EST)
Received: by iofh3 with SMTP id h3so47673813iof.3
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 01:07:53 -0800 (PST)
Received: from cmccmta3.chinamobile.com (cmccmta3.chinamobile.com. [221.176.66.81])
        by mx.google.com with ESMTP id o66si19846131ioi.203.2015.11.25.01.07.51
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 01:07:52 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH] mm/compaction: improve comment for compact_memory tunable knob handler
Date: Wed, 25 Nov 2015 17:07:28 +0800
Message-Id: <1448442448-3268-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, iamjoonsoo.kim@lge.com, riel@redhat.com, mina86@mina86.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Sysctl_compaction_handler() is the handler function for compact_memory
tunable knob under /proc/sys/vm, add the missing knob name to make this
more accurate in comment.

No functional change.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 mm/compaction.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index de3e1e7..ac6c694 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1708,7 +1708,10 @@ static void compact_nodes(void)
 /* The written value is actually unused, all memory is compacted */
 int sysctl_compact_memory;
 
-/* This is the entry point for compacting all nodes via /proc/sys/vm */
+/*
+ * This is the entry point for compacting all nodes via
+ * /proc/sys/vm/compact_memory
+ */
 int sysctl_compaction_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos)
 {
-- 
1.9.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
