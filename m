Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 7D8AF6B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:55:57 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so3401063iak.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 23:55:56 -0700 (PDT)
Message-ID: <50863F74.2080703@gmail.com>
Date: Tue, 23 Oct 2012 14:55:48 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: cma: alloc_contig_range: return early for err path
References: <1350974757-27876-1-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1350974757-27876-1-git-send-email-lliubbo@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, minchan@kernel.org, m.szyprowski@samsung.com, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-mm@kvack.org

On 10/23/2012 02:45 PM, Bob Liu wrote:
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

looks reasonable to me.

>   
>   	ret = __alloc_contig_migrate_range(&cc, start, end);
>   	if (ret)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
