Date: Thu, 29 Nov 2007 14:40:11 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 13/19] Use page_cache_xxx in fs/splice.c
Message-ID: <20071129034011.GU119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011147.323915994@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011147.323915994@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:11:05PM -0800, Christoph Lameter wrote:
> @@ -453,7 +454,7 @@ fill_it:
>  	 */
>  	while (page_nr < nr_pages)
>  		page_cache_release(pages[page_nr++]);
> -	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
> +	in->f_ra.prev_pos = page_cache_index(mapping, index);

	in->f_ra.prev_pos = page_cache_pos(mapping, index, 0);

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
