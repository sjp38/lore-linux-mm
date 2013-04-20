From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH 3.8-stable] mm/vmscan: fix error return in
 kswapd_run()
Date: Sat, 20 Apr 2013 11:22:01 +0800
Message-ID: <32756.4936750152$1366428132@news.gmane.org>
References: <1366383130-2500-1-git-send-email-jhbird.choi@samsung.com>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UTONM-0008Cz-Bt
	for glkm-linux-mm-2@m.gmane.org; Sat, 20 Apr 2013 05:22:08 +0200
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 461D36B0002
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 23:22:06 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 19 Apr 2013 21:22:05 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 3F8351FF0026
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 21:17:01 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3K3M2EB380170
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 21:22:02 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3K3M2So021369
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 21:22:02 -0600
Content-Disposition: inline
In-Reply-To: <1366383130-2500-1-git-send-email-jhbird.choi@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonghwan Choi <jhbird.choi@gmail.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jonghwan Choi <jhbird.choi@samsung.com>

On Fri, Apr 19, 2013 at 11:52:10PM +0900, Jonghwan Choi wrote:
>From: Gavin Shan <shangw@linux.vnet.ibm.com>
>
>This patch looks like it should be in the 3.8-stable tree, should we apply
>it?
>

Yes, I think so. If possible, please apply to 3.8-stable.

Thanks,
Gavin

>------------------
>
>From: "Gavin Shan <shangw@linux.vnet.ibm.com>"
>
>commit d5dc0ad928fb9e972001e552597fd0b794863f34 upstream
>
>Fix the error return value in kswapd_run().  The bug was introduced by
>commit d5dc0ad928fb ("mm/vmscan: fix error number for failed kthread").
>
>Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>Reviewed-by: Rik van Riel <riel@redhat.com>
>Reported-by: Wu Fengguang <fengguang.wu@intel.com>
>Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>Signed-off-by: Jonghwan Choi <jhbird.choi@samsung.com>
>---
> mm/vmscan.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/vmscan.c b/mm/vmscan.c
>index 196709f..8226b41 100644
>--- a/mm/vmscan.c
>+++ b/mm/vmscan.c
>@@ -3158,9 +3158,9 @@ int kswapd_run(int nid)
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
>1.7.10.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
