Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id C3E4E6B003D
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 10:50:04 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so1666615eaj.12
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 07:50:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e2si10067467eeg.156.2013.12.09.07.50.03
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 07:50:03 -0800 (PST)
Date: Mon, 9 Dec 2013 16:50:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: add show num_poisoned_pages when oom
Message-ID: <20131209155002.GE3597@dhcp22.suse.cz>
References: <52A592DE.7010302@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A592DE.7010302@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, rientjes@google.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 09-12-13 17:52:30, Xishi Qiu wrote:
> Show num_poisoned_pages when oom, it is helpful to find the reason.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

I would not expect the number of these pages would be too high to matter in
real life but having the information cannot be harmful in any way.

Acked-by: Michal Hocko <mhocko@suse.cz>

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
> -- 
> 1.7.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
