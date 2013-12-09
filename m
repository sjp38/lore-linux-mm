Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 37A9A6B0089
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 04:53:44 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so4932635pde.35
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 01:53:43 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ws5si6811040pab.6.2013.12.09.01.53.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 01:53:42 -0800 (PST)
Message-ID: <52A592DE.7010302@huawei.com>
Date: Mon, 9 Dec 2013 17:52:30 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: add show num_poisoned_pages when oom
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, rientjes@google.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>

Show num_poisoned_pages when oom, it is helpful to find the reason.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 lib/show_mem.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/show_mem.c b/lib/show_mem.c
index 5847a49..1cbdcd8 100644
--- a/lib/show_mem.c
+++ b/lib/show_mem.c
@@ -46,4 +46,7 @@ void show_mem(unsigned int filter)
 	printk("%lu pages in pagetable cache\n",
 		quicklist_total_size());
 #endif
+#ifdef CONFIG_MEMORY_FAILURE
+	printk("%lu pages poisoned\n", atomic_long_read(&num_poisoned_pages));
+#endif
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
