Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id D543D6B003D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:35:27 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id a15so2517121eae.13
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:35:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m44si15989577eeo.100.2013.12.10.12.35.25
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 12:35:26 -0800 (PST)
Date: Tue, 10 Dec 2013 15:35:01 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386707701-qoyirqe1-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386667175-19952-6-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386667175-19952-6-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 06/12] sched/numa: make numamigrate_update_ratelimit
 static
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 05:19:29PM +0800, Wanpeng Li wrote:
> Make numamigrate_update_ratelimit static.
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/migrate.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 7ad81e0..b1b6663 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1592,7 +1592,8 @@ bool migrate_ratelimited(int node)
>  }
>  
>  /* Returns true if the node is migrate rate-limited after the update */
> -bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
> +static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
> +						unsigned long nr_pages)
>  {
>  	bool rate_limited = false;
>  
> -- 
> 1.7.7.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
