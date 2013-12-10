Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 592F16B005A
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:35:39 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id cc10so5947405wib.16
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:35:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id mx2si1608236wic.24.2013.12.10.12.35.25
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 12:35:26 -0800 (PST)
Date: Tue, 10 Dec 2013 15:34:54 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386707694-ag3197mb-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1386667175-19952-1-git-send-email-liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 01/12] sched/numa: fix set cpupid on page migration
 twice against thp
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 05:19:24PM +0800, Wanpeng Li wrote:
> commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over
> the cpupid at page migration time, there is unnecessary to set it again
> in function migrate_misplaced_transhuge_page, this patch fix it.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/migrate.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index bb94004..fdb70f7 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1736,8 +1736,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	if (!new_page)
>  		goto out_fail;
>  
> -	page_cpupid_xchg_last(new_page, page_cpupid_last(page));
> -
>  	isolated = numamigrate_isolate_page(pgdat, page);
>  	if (!isolated) {
>  		put_page(new_page);
> -- 
> 1.7.7.6
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
