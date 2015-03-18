Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 933A66B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 09:44:29 -0400 (EDT)
Received: by webcq43 with SMTP id cq43so32722268web.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 06:44:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xb4si29025624wjc.178.2015.03.18.06.44.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 06:44:28 -0700 (PDT)
Message-ID: <55098139.7090206@suse.cz>
Date: Wed, 18 Mar 2015 14:44:25 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1 linux-next] mm/page_alloc.c: don't redeclare mt in
 get_pageblock_migratetype()
References: <1426097333-24131-1-git-send-email-fabf@skynet.be>
In-Reply-To: <1426097333-24131-1-git-send-email-fabf@skynet.be>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

On 03/11/2015 07:08 PM, Fabian Frederick wrote:
> mt is already declared above and global value not used after loop.
> This fixes a shadow warning.
>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/page_alloc.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1b84950..4ec8c23 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1653,7 +1653,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
>   	if (order >= pageblock_order - 1) {
>   		struct page *endpage = page + (1 << order) - 1;
>   		for (; page < endpage; page += pageblock_nr_pages) {
> -			int mt = get_pageblock_migratetype(page);
> +			mt = get_pageblock_migratetype(page);
>   			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
>   				set_pageblock_migratetype(page,
>   							  MIGRATE_MOVABLE);
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
