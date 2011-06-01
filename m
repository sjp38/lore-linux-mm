Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE746B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 13:04:04 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p51H41vN028006
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 10:04:02 -0700
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by wpaz1.hot.corp.google.com with ESMTP id p51H3nvJ008729
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 1 Jun 2011 10:04:00 -0700
Received: by pxi9 with SMTP id 9so5515pxi.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 10:04:00 -0700 (PDT)
Date: Wed, 1 Jun 2011 10:04:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 7/14] drm/i915: adjust to new truncate_range
In-Reply-To: <20110601004314.GD4433@infradead.org>
Message-ID: <alpine.LSU.2.00.1106011002420.23468@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils> <alpine.LSU.2.00.1105301743500.5482@sister.anvils> <20110601004314.GD4433@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Keith Packard <keithp@keithp.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 31 May 2011, Christoph Hellwig wrote:

> >  	/* Our goal here is to return as much of the memory as
> >  	 * is possible back to the system as we are called from OOM.
> >  	 * To do this we must instruct the shmfs to drop all of its
> > -	 * backing pages, *now*. Here we mirror the actions taken
> > -	 * when by shmem_delete_inode() to release the backing store.
> > +	 * backing pages, *now*.
> >  	 */
> >  	inode = obj->base.filp->f_path.dentry->d_inode;
> > -	truncate_inode_pages(inode->i_mapping, 0);
> >  	if (inode->i_op->truncate_range)
> >  		inode->i_op->truncate_range(inode, 0, (loff_t)-1);
> > +	else
> > +		truncate_inode_pages(inode->i_mapping, 0);
> 
> Given that it relies on beeing on shmemfs it should just call it
> directly.

As agreed in other mail, I'll do a v2 series in a few days,
making that change - thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
