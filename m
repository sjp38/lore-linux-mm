Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C97C6B0292
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 14:58:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so72901173pge.9
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 11:58:28 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id l125si2990462pfl.219.2017.08.09.11.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 11:58:26 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id y192so6556024pgd.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 11:58:26 -0700 (PDT)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [PATCH] vmstat: Fix wrong comment
Date: Thu, 10 Aug 2017 03:58:16 +0900
Message-Id: <20170809185816.11244-1-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com
Cc: vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, SeongJae Park <sj38.park@gmail.com>

Comment for pagetypeinfo_showblockcount() is mistakenly duplicated from
pagetypeinfo_show_free()'s comment.  This commit fixes it.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
Fixes: 467c996c1e19 ("Print out statistics in relation to fragmentation avoidance to /proc/pagetypeinfo")
---
 mm/vmstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9a4441bbeef2..c30cda773d4a 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1250,7 +1250,7 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 	seq_putc(m, '\n');
 }
 
-/* Print out the free pages at each order for each migratetype */
+/* Print out the number of pageblocks for each migratetype */
 static int pagetypeinfo_showblockcount(struct seq_file *m, void *arg)
 {
 	int mtype;
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
