Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E3F2B6B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 11:40:29 -0400 (EDT)
Message-ID: <1375198768.10300.9.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm/hotplug: remove unnecessary BUG_ON in
 __offline_pages()
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 30 Jul 2013 09:39:28 -0600
In-Reply-To: <51F761E7.5090403@huawei.com>
References: <51F761E7.5090403@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2013-07-30 at 14:49 +0800, Xishi Qiu wrote:
> I think we can remove "BUG_ON(start_pfn >= end_pfn)" in __offline_pages(),
> because in memory_block_action() "nr_pages = PAGES_PER_SECTION * sections_per_block" 
> is always greater than 0.

BUG_ON() is used for checking a condition that should never happen,
unless there is a bug.  So, to me, what you described seems to match
with the use of BUG_ON() to prevent a potential bug in the caller.

Thanks,
-Toshi


> memory_block_action()
> 	offline_pages()
> 		__offline_pages()
> 			BUG_ON(start_pfn >= end_pfn)
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/memory_hotplug.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index ca1dd3a..8e333f9 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1472,7 +1472,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	struct zone *zone;
>  	struct memory_notify arg;
>  
> -	BUG_ON(start_pfn >= end_pfn);
>  	/* at least, alignment against pageblock is necessary */
>  	if (!IS_ALIGNED(start_pfn, pageblock_nr_pages))
>  		return -EINVAL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
