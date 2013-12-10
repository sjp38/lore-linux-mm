Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id EFE126B0062
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 20:53:44 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so6259410pde.41
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 17:53:44 -0800 (PST)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id d2si8889163pba.211.2013.12.09.17.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 17:53:43 -0800 (PST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 11:53:40 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 9AE4B2BB0056
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:53:37 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA1ZHfK9175362
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:35:17 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA1rZTj029467
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:53:36 +1100
Date: Tue, 10 Dec 2013 09:53:34 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] mm: add show num_poisoned_pages when oom
Message-ID: <52a67427.c206440a.62e8.34eeSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <52A670AC.6090504@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A670AC.6090504@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 09:38:52AM +0800, Xishi Qiu wrote:
>Show num_poisoned_pages when oom, it is a little helpful to find the reason.
>Also it will be emitted anytime show_mem() is called.
>
>Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>Acked-by: Michal Hocko <mhocko@suse.cz>
>Acked-by: David Rientjes <rientjes@google.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> lib/show_mem.c |    3 +++
> 1 files changed, 3 insertions(+), 0 deletions(-)
>
>diff --git a/lib/show_mem.c b/lib/show_mem.c
>index 5847a49..1cbdcd8 100644
>--- a/lib/show_mem.c
>+++ b/lib/show_mem.c
>@@ -46,4 +46,7 @@ void show_mem(unsigned int filter)
> 	printk("%lu pages in pagetable cache\n",
> 		quicklist_total_size());
> #endif
>+#ifdef CONFIG_MEMORY_FAILURE
>+	printk("%lu pages hwpoisoned\n", atomic_long_read(&num_poisoned_pages));
>+#endif
> }
>-- 
>1.7.1
>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
