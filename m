Message-ID: <396325170.21410@ustc.edu.cn>
Date: Thu, 29 Nov 2007 16:32:41 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch 19/19] Use page_cache_xxx in drivers/block/rd.c
References: <20071129011052.866354847@sgi.com> <20071129011148.733429253@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011148.733429253@sgi.com>
Message-Id: <E1Ixep7-0004SV-Pq@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:11:11PM -0800, Christoph Lameter wrote:
> Use page_cache_xxx in drivers/block/rd.c
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  drivers/block/rd.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> Index: mm/drivers/block/rd.c
> ===================================================================
> --- mm.orig/drivers/block/rd.c	2007-11-28 12:19:49.673905513 -0800
> +++ mm/drivers/block/rd.c	2007-11-28 14:13:01.076977633 -0800
> @@ -122,7 +122,7 @@ static void make_page_uptodate(struct pa
>  			}
>  		} while ((bh = bh->b_this_page) != head);
>  	} else {
> -		memset(page_address(page), 0, PAGE_CACHE_SIZE);
> +		memset(page_address(page), 0, page_cache_size(page_mapping(page)));
>  	}
>  	flush_dcache_page(page);
>  	SetPageUptodate(page);
> @@ -215,9 +215,9 @@ static const struct address_space_operat
>  static int rd_blkdev_pagecache_IO(int rw, struct bio_vec *vec, sector_t sector,
>  				struct address_space *mapping)
>  {
> -	pgoff_t index = sector >> (PAGE_CACHE_SHIFT - 9);
> +	pgoff_t index = sector >> (page_cache_size(mapping) - 9);
                                   page_cache_shift

Cheers,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
