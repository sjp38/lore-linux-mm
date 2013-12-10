Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4D86B0055
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 20:47:50 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id tp5so7644995ieb.11
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 17:47:50 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTP id mv8si278506igb.73.2013.12.09.17.47.24
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 17:47:49 -0800 (PST)
Message-ID: <52A670AC.6090504@huawei.com>
Date: Tue, 10 Dec 2013 09:38:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] mm: add show num_poisoned_pages when oom
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>

Show num_poisoned_pages when oom, it is a little helpful to find the reason.
Also it will be emitted anytime show_mem() is called.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
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
+	printk("%lu pages hwpoisoned\n", atomic_long_read(&num_poisoned_pages));
+#endif
 }
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
