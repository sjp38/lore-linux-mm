Date: Thu, 29 Nov 2007 14:54:15 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 17/19] Use page_cache_xxx in fs/reiserfs
Message-ID: <20071129035415.GX119954183@sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011148.263927341@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011148.263927341@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:11:09PM -0800, Christoph Lameter wrote:
> @@ -2000,11 +2001,13 @@ static int grab_tail_page(struct inode *
>  	/* we want the page with the last byte in the file,
>  	 ** not the page that will hold the next byte for appending
>  	 */
> -	unsigned long index = (p_s_inode->i_size - 1) >> PAGE_CACHE_SHIFT;
> +	unsigned long index = page_cache_index(p_s_inode->i_mapping,
> +						p_s_inode->i_size - 1);
>  	unsigned long pos = 0;
>  	unsigned long start = 0;
>  	unsigned long blocksize = p_s_inode->i_sb->s_blocksize;
> -	unsigned long offset = (p_s_inode->i_size) & (PAGE_CACHE_SIZE - 1);
> +	unsigned long offset = page_cache_index(p_s_inode->i_mapping,
> +							p_s_inode->i_size);

	unsigned long offset = page_cache_offset(p_s_inode->i_mapping,

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
