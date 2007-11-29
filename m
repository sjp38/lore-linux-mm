Date: Thu, 29 Nov 2007 15:02:29 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 13/19] Use page_cache_xxx in fs/splice.c
Message-ID: <20071129040229.GB119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011147.323915994@sgi.com> <20071129034011.GU119954183@sgi.com> <Pine.LNX.4.64.0711281949550.20688@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711281949550.20688@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 07:50:16PM -0800, Christoph Lameter wrote:
> On Thu, 29 Nov 2007, David Chinner wrote:
> 
> > On Wed, Nov 28, 2007 at 05:11:05PM -0800, Christoph Lameter wrote:
> > > @@ -453,7 +454,7 @@ fill_it:
> > >  	 */
> > >  	while (page_nr < nr_pages)
> > >  		page_cache_release(pages[page_nr++]);
> > > -	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
> > > +	in->f_ra.prev_pos = page_cache_index(mapping, index);
> > 
> > 	in->f_ra.prev_pos = page_cache_pos(mapping, index, 0);
> > 
> 
> splice.c: Wrong inline function used
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  fs/splice.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: mm/fs/splice.c
> ===================================================================
> --- mm.orig/fs/splice.c	2007-11-28 19:48:43.246633219 -0800
> +++ mm/fs/splice.c	2007-11-28 19:49:06.405882592 -0800
> @@ -454,7 +454,7 @@ fill_it:
>  	 */
>  	while (page_nr < nr_pages)
>  		page_cache_release(pages[page_nr++]);
> -	in->f_ra.prev_pos = page_cache_index(mapping, index);
> +	in->f_ra.prev_pos = page_cache_pos(mapping, index, 0);
>  
>  	if (spd.nr_pages)
>  		return splice_to_pipe(pipe, &spd);

Ok.

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
