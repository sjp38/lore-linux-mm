Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4AC706B0027
	for <linux-mm@kvack.org>; Tue, 31 May 2011 20:42:30 -0400 (EDT)
Date: Tue, 31 May 2011 20:42:25 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/14] tmpfs: add shmem_read_mapping_page_gfp
Message-ID: <20110601004225.GC4433@infradead.org>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
 <alpine.LSU.2.00.1105301739080.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1105301739080.5482@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

> (shmem_read_mapping_page_gfp or shmem_read_cache_page_gfp?  Generally
> the read_mapping_page functions use the mapping's ->readpage, and the
> read_cache_page functions use the supplied filler, so I think
> read_cache_page_gfp was slightly misnamed.)

What about just shmem_read_page?  It's not using the pagecache, so
no need for the mapping or cache, and the _gfp really is just a hack
because the old pagecache APIs didn't allow to pass the gfp flags.
For a new API there's no need for that.

> +static inline struct page *shmem_read_mapping_page(
> +				struct address_space *mapping, pgoff_t index)
> +{
> +	return shmem_read_mapping_page_gfp(mapping, index,
> +				mapping_gfp_mask(mapping));
> +}

This really shouldn't be in pagemap.h.  For now probably in shmem_fs.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
