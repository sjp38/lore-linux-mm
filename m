Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6EB6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 11:23:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so101336701pfw.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 08:23:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z13si12719197pfi.155.2016.05.18.08.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 08:23:17 -0700 (PDT)
Subject: Re: [PATCH] mm: fix duplicate words and typos
References: <1463538956-7342-1-git-send-email-lip@dtdream.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <573C88E0.8070405@infradead.org>
Date: Wed, 18 May 2016 08:23:12 -0700
MIME-Version: 1.0
In-Reply-To: <1463538956-7342-1-git-send-email-lip@dtdream.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Peng <lip@dtdream.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/17/16 19:35, Li Peng wrote:
> Signed-off-by: Li Peng <lip@dtdream.com>
> ---
>  mm/memcontrol.c | 2 +-
>  mm/page_alloc.c | 6 +++---
>  mm/vmscan.c     | 7 +++----
>  mm/zswap.c      | 2 +-
>  4 files changed, 8 insertions(+), 9 deletions(-)

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 142cb61..8ff5a79 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c

> @@ -3267,8 +3267,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  			/*
>  			 * There should be no need to raise the scanning
>  			 * priority if enough pages are already being scanned
> -			 * that that high watermark would be met at 100%
> -			 * efficiency.
> +			 * that high watermark would be met at 100% efficiency.

I think that this one wasn't wrong, just confusing.  Maybe change it to:
			* that the high watermark would be met at 100% efficiency.

>  			 */
>  			if (kswapd_shrink_zone(zone, end_zone, &sc))
>  				raise_priority = false;
> diff --git a/mm/zswap.c b/mm/zswap.c
> index de0f119b..6d829d7 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -928,7 +928,7 @@ static int zswap_writeback_entry(struct zpool *pool, unsigned long handle)
>  	* a load may happening concurrently
>  	* it is safe and okay to not free the entry
>  	* if we free the entry in the following put
> -	* it it either okay to return !0
> +	* it either okay to return !0

That's still confusing.  Needs some kind of help.

>  	*/
>  fail:
>  	spin_lock(&tree->lock);
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
