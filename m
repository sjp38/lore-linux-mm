Date: Tue, 4 Dec 2007 16:45:48 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [patch 07/19] Use page_cache_xxx in mm/migrate.c
Message-ID: <20071204054547.GY119954183@sgi.com>
References: <20071130173448.951783014@sgi.com> <20071130173507.749913641@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071130173507.749913641@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 30, 2007 at 09:34:55AM -0800, Christoph Lameter wrote:
> Use page_cache_xxx in mm/migrate.c
> 
> Reviewed-by: Dave Chinner <dgc@sgi.com>
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> ---
>  mm/migrate.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: mm/mm/migrate.c
> ===================================================================
> --- mm.orig/mm/migrate.c	2007-11-28 12:27:32.184464256 -0800
> +++ mm/mm/migrate.c	2007-11-28 14:10:49.200977227 -0800
> @@ -197,7 +197,7 @@ static void remove_file_migration_ptes(s
>  	struct vm_area_struct *vma;
>  	struct address_space *mapping = page_mapping(new);
>  	struct prio_tree_iter iter;
> -	pgoff_t pgoff = new->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> +	pgoff_t pgoff = new->index << mapping_order(mapping);
>  
>  	if (!mapping)
>  		return;

Mapping could be NULL, therefore the setting of pgoff needs to
occur after the !mapping check.

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
