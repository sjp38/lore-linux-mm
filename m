From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/vmscan: fix error return in kswapd_run()
Date: Tue, 2 Apr 2013 19:20:41 +0800
Message-ID: <7453.36250770396$1364901703@news.gmane.org>
References: <515ABC79.5060900@huawei.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UMzHO-000114-My
	for glkm-linux-mm-2@m.gmane.org; Tue, 02 Apr 2013 13:21:30 +0200
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 6D2EE6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 07:20:52 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Apr 2013 16:47:59 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id EC6A91258023
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 16:52:03 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r32BKfOa262634
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 16:50:42 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r32BKhA3009806
	for <linux-mm@kvack.org>; Tue, 2 Apr 2013 22:20:43 +1100
Content-Disposition: inline
In-Reply-To: <515ABC79.5060900@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, hughd@google.com, riel@redhat.com, khlebnikov@openvz.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhangdianfang <zhangdianfang@huawei.com>

On Tue, Apr 02, 2013 at 07:09:45PM +0800, Xishi Qiu wrote:
>Fix the error return value in kswapd_run(). The bug was
>introduced by commit d5dc0ad928fb9e972001e552597fd0b794863f34
>"mm/vmscan: fix error number for failed kthread".
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>---
> mm/vmscan.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/mm/vmscan.c b/mm/vmscan.c
>index 88c5fed..950636e 100644
>--- a/mm/vmscan.c
>+++ b/mm/vmscan.c
>@@ -3188,9 +3188,9 @@ int kswapd_run(int nid)
> 	if (IS_ERR(pgdat->kswapd)) {
> 		/* failure at boot is fatal */
> 		BUG_ON(system_state == SYSTEM_BOOTING);
>-		pgdat->kswapd = NULL;
> 		pr_err("Failed to start kswapd on node %d\n", nid);
> 		ret = PTR_ERR(pgdat->kswapd);
>+		pgdat->kswapd = NULL;
> 	}
> 	return ret;
> }
>-- 
>1.7.6.1
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
