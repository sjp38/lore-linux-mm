Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 153906B0390
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 04:57:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o70so27504181wrb.11
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 01:57:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y13si23557752wrb.286.2017.04.04.01.57.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 01:57:29 -0700 (PDT)
Date: Tue, 4 Apr 2017 10:57:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + fix-print-order-in-show_free_areas.patch added to -mm tree
Message-ID: <20170404085725.GF15132@dhcp22.suse.cz>
References: <58e2c885.fYYyNuCxKh7sHx78%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58e2c885.fYYyNuCxKh7sHx78%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: apolyakov@beget.ru, apolyakov@beget.com, mgorman@techsingularity.net, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>

JFTR. Joe, has already noticed this
http://lkml.kernel.org/r/2aaf6f1701ee78582743d91359018689d5826e82.1489628459.git.joe@perches.com
and I have requested to split out the fix from the rest of the
whitespace noise
http://lkml.kernel.org/r/20170316105733.GC30508@dhcp22.suse.cz
but Joe hasn't really followed up and I didn't get to do it myself.

On Mon 03-04-17 15:11:17, Andrew Morton wrote:
> From: Alexander Polakov <apolyakov@beget.ru>
> Subject: mmpage_alloc.c: fix print order in show_free_areas()
> 
> Fixes: 11fb998986a72a ("mm: move most file-based accounting to the node")
> Link: http://lkml.kernel.org/r/1490377730.30219.2.camel@beget.ru
> Signed-off-by: Alexander Polyakov <apolyakov@beget.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Even though this cannot cause any crash or misbehaving it is still
confusing enough to be worth backporting to stable

Cc: stable # 4.8+
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
> 
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN mm/page_alloc.c~fix-print-order-in-show_free_areas mm/page_alloc.c
> --- a/mm/page_alloc.c~fix-print-order-in-show_free_areas
> +++ a/mm/page_alloc.c
> @@ -4519,13 +4519,13 @@ void show_free_areas(unsigned int filter
>  			K(node_page_state(pgdat, NR_FILE_MAPPED)),
>  			K(node_page_state(pgdat, NR_FILE_DIRTY)),
>  			K(node_page_state(pgdat, NR_WRITEBACK)),
> +			K(node_page_state(pgdat, NR_SHMEM)),
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
>  			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
>  					* HPAGE_PMD_NR),
>  			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
>  #endif
> -			K(node_page_state(pgdat, NR_SHMEM)),
>  			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
>  			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
>  			node_page_state(pgdat, NR_PAGES_SCANNED),
> _
> 
> Patches currently in -mm which might be from apolyakov@beget.ru are
> 
> fix-print-order-in-show_free_areas.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
