Date: Thu, 17 May 2007 12:38:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] Mark page cache pages as __GFP_PAGECACHE instead of
 __GFP_MOVABLE
Message-Id: <20070517123854.6cea6338.akpm@linux-foundation.org>
In-Reply-To: <20070517101203.3113.81852.sendpatchset@skynet.skynet.ie>
References: <20070517101022.3113.15456.sendpatchset@skynet.skynet.ie>
	<20070517101203.3113.81852.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007 11:12:03 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> --- linux-2.6.22-rc1-mm1-025_gfphighuser/fs/buffer.c	2007-05-16 22:55:50.000000000 +0100
> +++ linux-2.6.22-rc1-mm1-030_pagecache_mark/fs/buffer.c	2007-05-16 23:07:30.000000000 +0100
> @@ -1009,7 +1009,7 @@ grow_dev_page(struct block_device *bdev,
>  	struct buffer_head *bh;
>  
>  	page = find_or_create_page(inode->i_mapping, index,
> -					GFP_NOFS|__GFP_RECLAIMABLE);
> +					GFP_NOFS_PAGECACHE);
>  	if (!page)
>  		return NULL;
>  

I ended up with

        page = find_or_create_page(inode->i_mapping, index,
                (mapping_gfp_mask(inode->i_mapping) & ~__GFP_FS)|__GFP_MOVABLE);

here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
