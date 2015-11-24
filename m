Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD8D6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 03:25:11 -0500 (EST)
Received: by oiww189 with SMTP id w189so5576818oiw.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 00:25:10 -0800 (PST)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id a72si9660232oib.109.2015.11.24.00.25.09
        for <linux-mm@kvack.org>;
        Tue, 24 Nov 2015 00:25:10 -0800 (PST)
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: [PATCH] mm/compaction: improve comment
Date: Tue, 24 Nov 2015 16:23:47 +0800
Message-Id: <1448353427-4240-1-git-send-email-baiyaowei@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, iamjoonsoo.kim@lge.com, riel@redhat.com, mina86@mina86.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Make comment more accurate.

Signed-off-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
---
 mm/compaction.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index de3e1e7..b3cf915 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1708,7 +1708,9 @@ static void compact_nodes(void)
 /* The written value is actually unused, all memory is compacted */
 int sysctl_compact_memory;
 
-/* This is the entry point for compacting all nodes via /proc/sys/vm */
+/* This is the entry point for compacting all nodes via
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
