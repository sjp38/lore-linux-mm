Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 4CF986B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 09:44:17 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so1502701vbk.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 06:44:16 -0700 (PDT)
Message-ID: <4FD9EAAC.1060100@gmail.com>
Date: Thu, 14 Jun 2012 09:44:12 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: complement page reclaim comment
References: <1339680158-26657-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <1339680158-26657-1-git-send-email-liwp.linux@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, trivial@kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, kosaki.motohiro@gmail.com

(6/14/12 9:22 AM), Wanpeng Li wrote:
> From: Wanpeng Li<liwp@linux.vnet.ibm.com>
> 
> Signed-off-by: Wanpeng Li<liwp.linux@gmail.com>
> ---
>   mm/vmscan.c |    1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ed823df..603c96f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3203,6 +3203,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>    * Reasons page might not be evictable:
>    * (1) page's mapping marked unevictable
>    * (2) page is part of an mlocked VMA
> + * (3) page mapped into SHM_LOCK'd shared memory regions

This is one of "marked unevictable".


>    *
>    */
>   int page_evictable(struct page *page, struct vm_area_struct *vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
