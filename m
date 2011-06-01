Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1946B0029
	for <linux-mm@kvack.org>; Tue, 31 May 2011 20:43:29 -0400 (EDT)
Date: Tue, 31 May 2011 20:43:14 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 7/14] drm/i915: adjust to new truncate_range
Message-ID: <20110601004314.GD4433@infradead.org>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
 <alpine.LSU.2.00.1105301743500.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1105301743500.5482@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Keith Packard <keithp@keithp.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

>  	/* Our goal here is to return as much of the memory as
>  	 * is possible back to the system as we are called from OOM.
>  	 * To do this we must instruct the shmfs to drop all of its
> -	 * backing pages, *now*. Here we mirror the actions taken
> -	 * when by shmem_delete_inode() to release the backing store.
> +	 * backing pages, *now*.
>  	 */
>  	inode = obj->base.filp->f_path.dentry->d_inode;
> -	truncate_inode_pages(inode->i_mapping, 0);
>  	if (inode->i_op->truncate_range)
>  		inode->i_op->truncate_range(inode, 0, (loff_t)-1);
> +	else
> +		truncate_inode_pages(inode->i_mapping, 0);

Given that it relies on beeing on shmemfs it should just call it
directly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
