Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 239B66B0022
	for <linux-mm@kvack.org>; Wed,  4 May 2011 05:49:34 -0400 (EDT)
Date: Wed, 4 May 2011 11:49:30 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: +
	writeback-split-inode_wb_list_lock-into-bdi_writebacklist_lock-fix-f
	ix.patch added to -mm tree
Message-ID: <20110504094930.GA30358@lst.de>
References: <201105032057.p43Kvj4C009848@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201105032057.p43Kvj4C009848@imap1.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, May 03, 2011 at 01:57:44PM -0700, akpm@linux-foundation.org wrote:
>  	struct backing_dev_info *old = inode->i_data.backing_dev_info;
>  
> -	if (dst == old)
> +	if (dst == old)			/* deadlock avoidance */

That's not an overly useful comment.  It should be a proper block coment
documentation how that we could ever end up with the same bdi as
destination and source.

Which is something I wanted to ask Hugh anyway - do you have traces explaining
how this happens for you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
