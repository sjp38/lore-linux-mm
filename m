Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2776B00EA
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 16:49:53 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hq4so4440845wib.2
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:49:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cd6si5582625wjc.57.2013.12.09.13.49.50
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 13:49:50 -0800 (PST)
Date: Mon, 09 Dec 2013 16:49:38 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1386625778-kutyp5f6-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <52A592DE.7010302@huawei.com>
References: <52A592DE.7010302@huawei.com>
Subject: Re: [PATCH] mm: add show num_poisoned_pages when oom
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Dec 09, 2013 at 05:52:30PM +0800, Xishi Qiu wrote:
> Show num_poisoned_pages when oom, it is helpful to find the reason.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  lib/show_mem.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/show_mem.c b/lib/show_mem.c
> index 5847a49..1cbdcd8 100644
> --- a/lib/show_mem.c
> +++ b/lib/show_mem.c
> @@ -46,4 +46,7 @@ void show_mem(unsigned int filter)
>  	printk("%lu pages in pagetable cache\n",
>  		quicklist_total_size());
>  #endif
> +#ifdef CONFIG_MEMORY_FAILURE
> +	printk("%lu pages poisoned\n", atomic_long_read(&num_poisoned_pages));
> +#endif
>  }

I think that just "poisoned" could be confusing because this word seems to
be used also in other context (like slab and list_debug handling.)
"hwpoisoned" or "hardware corrupted" (which is the same label in /proc/meminfo)
looks better to me.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
