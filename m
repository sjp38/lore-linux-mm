Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2F66B004D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:35:37 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so5508476wes.38
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:35:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v6si5329907eel.154.2013.12.10.12.35.36
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 12:35:36 -0800 (PST)
Date: Tue, 10 Dec 2013 15:35:05 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386707705-w5s8rtqp-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386667175-19952-7-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386667175-19952-7-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 07/12] sched/numa: fix set cpupid on page migration
 twice against normal page
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 05:19:30PM +0800, Wanpeng Li wrote:
> commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over
> the cpupid at page migration time, there is unnecessary to set it again
> in function alloc_misplaced_dst_page, this patch fix it.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/migrate.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index b1b6663..508cde4 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1557,8 +1557,6 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
>  					  __GFP_NOMEMALLOC | __GFP_NORETRY |
>  					  __GFP_NOWARN) &
>  					 ~GFP_IOFS, 0);
> -	if (newpage)
> -		page_cpupid_xchg_last(newpage, page_cpupid_last(page));
>  
>  	return newpage;
>  }
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
