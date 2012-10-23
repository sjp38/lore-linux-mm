Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 7A2786B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 08:13:14 -0400 (EDT)
Received: from eusync4.samsung.com (mailout3.w1.samsung.com [210.118.77.13])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MCC0097EHYSXZ80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 23 Oct 2012 13:13:40 +0100 (BST)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MCC00AQZHXZXL10@eusync4.samsung.com> for linux-mm@kvack.org;
 Tue, 23 Oct 2012 13:13:12 +0100 (BST)
Message-id: <508689D7.30102@samsung.com>
Date: Tue, 23 Oct 2012 14:13:11 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: cma: alloc_contig_range: return early for err path
References: <1350974757-27876-1-git-send-email-lliubbo@gmail.com>
In-reply-to: <1350974757-27876-1-git-send-email-lliubbo@gmail.com>
Content-type: text/plain; charset=ISO-8859-2; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-mm@kvack.org

Hello,

On 10/23/2012 8:45 AM, Bob Liu wrote:

> If start_isolate_page_range() failed, unset_migratetype_isolate() has been
> done inside it.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>   mm/page_alloc.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bb90971..b0012ab 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5825,7 +5825,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>   	ret = start_isolate_page_range(pfn_max_align_down(start),
>   				       pfn_max_align_up(end), migratetype);
>   	if (ret)
> -		goto done;
> +		return ret;
>
>   	ret = __alloc_contig_migrate_range(&cc, start, end);
>   	if (ret)
>

Thanks for the fix, I've applied it to my kernel tree.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
