Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1FF6B00A6
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 16:20:22 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w61so1251422wes.15
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 13:20:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id eo13si2066422wid.79.2013.12.06.13.20.21
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 13:20:22 -0800 (PST)
Date: Fri, 06 Dec 2013 16:19:55 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386364795-hks9q1oj-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386321136-27538-5-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386321136-27538-5-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 5/6] sched/numa: make numamigrate_isolate_page static
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 06, 2013 at 05:12:15PM +0800, Wanpeng Li wrote:
> Make numamigrate_update_ratelimit static.

Please change this function name, too :)

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/migrate.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index fdb70f7..7ad81e0 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1616,7 +1616,7 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
>  	return rate_limited;
>  }
>  
> -int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
> +static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
>  {
>  	int page_lru;
>  
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
