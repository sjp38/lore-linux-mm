Message-ID: <396327928.04162@ustc.edu.cn>
Date: Thu, 29 Nov 2007 17:18:40 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch 06/19] Use page_cache_xxx in mm/filemap_xip.c
References: <20071129011052.866354847@sgi.com> <20071129011145.652104648@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071129011145.652104648@sgi.com>
Message-Id: <E1IxfXc-0005sC-9J@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 28, 2007 at 05:10:58PM -0800, Christoph Lameter wrote:
> Use page_cache_xxx in mm/filemap_xip.c
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  mm/filemap_xip.c |   28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
> 
> Index: mm/mm/filemap_xip.c
> ===================================================================
> --- mm.orig/mm/filemap_xip.c	2007-11-28 12:27:32.155962689 -0800
> +++ mm/mm/filemap_xip.c	2007-11-28 14:10:46.124978450 -0800
> @@ -60,24 +60,24 @@ do_xip_mapping_read(struct address_space


> -			nr = ((isize - 1) & ~PAGE_CACHE_MASK) + 1;
> +			nr = page_cache_next(mapping, size - 1) + 1;
                             page_cache_offset(mapping, isize - 1) + 1;
                         or: page_cache_next(mapping, isize);


Cheers,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
