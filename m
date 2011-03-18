Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BAE528D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 10:24:41 -0400 (EDT)
Date: Fri, 18 Mar 2011 15:24:14 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] xfs: flush vmap aliases when mapping fails
Message-ID: <20110318142414.GV2140@cmpxchg.org>
References: <1299713876-7747-1-git-send-email-david@fromorbit.com>
 <20110310073751.GB25374@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310073751.GB25374@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, npiggin@kernel.dk, linux-mm@kvack.org

On Thu, Mar 10, 2011 at 02:37:51AM -0500, Christoph Hellwig wrote:
> On Thu, Mar 10, 2011 at 10:37:56AM +1100, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > On 32 bit systems, vmalloc space is limited and XFS can chew through
> > it quickly as the vmalloc space is lazily freed. This can result in
> > failure to map buffers, even when there is apparently large amounts
> > of vmalloc space available. Hence, if we fail to map a buffer, purge
> > the aliases that have not yet been freed to hopefuly free up enough
> > vmalloc space to allow a retry to succeed.
> 
> IMHO this should be done by vm_map_ram internally.  If we can't get the
> core code fixes we can put this in as a last resort.

Agreed, this should be fixed in the vmalloc-ator.

It is already supposed to purge the lazy-freed mappings before it
fails an allocation, I am trying to figure out what's going on.

Your proposed workaround looks fine to me until vmalloc is fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
