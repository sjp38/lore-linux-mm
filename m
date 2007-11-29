Date: Thu, 29 Nov 2007 15:08:37 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 17/19] Use page_cache_xxx in fs/reiserfs
Message-ID: <20071129040837.GE119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011148.263927341@sgi.com> <20071129035415.GX119954183@sgi.com> <Pine.LNX.4.64.0711282001410.20688@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711282001410.20688@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Chinner <dgc@sgi.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 08:02:01PM -0800, Christoph Lameter wrote:
> On Thu, 29 Nov 2007, David Chinner wrote:
> 
> > >  	unsigned long start = 0;
> > >  	unsigned long blocksize = p_s_inode->i_sb->s_blocksize;
> > > -	unsigned long offset = (p_s_inode->i_size) & (PAGE_CACHE_SIZE - 1);
> > > +	unsigned long offset = page_cache_index(p_s_inode->i_mapping,
> > > +							p_s_inode->i_size);
> > 
> > 	unsigned long offset = page_cache_offset(p_s_inode->i_mapping,
> > 
> 
> 
> 
> Reiserfs: Wrong type of inline function
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  fs/reiserfs/inode.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: mm/fs/reiserfs/inode.c
> ===================================================================
> --- mm.orig/fs/reiserfs/inode.c	2007-11-28 19:59:41.083133259 -0800
> +++ mm/fs/reiserfs/inode.c	2007-11-28 20:00:23.317882809 -0800
> @@ -2006,7 +2006,7 @@ static int grab_tail_page(struct inode *
>  	unsigned long pos = 0;
>  	unsigned long start = 0;
>  	unsigned long blocksize = p_s_inode->i_sb->s_blocksize;
> -	unsigned long offset = page_cache_index(p_s_inode->i_mapping,
> +	unsigned long offset = page_cache_offset(p_s_inode->i_mapping,
>  							p_s_inode->i_size);
>  	struct buffer_head *bh;
>  	struct buffer_head *head;

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
