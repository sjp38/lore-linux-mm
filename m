Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5195A8D0039
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 10:24:26 -0400 (EDT)
Date: Thu, 17 Mar 2011 10:24:18 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] xfs: flush vmap aliases when mapping fails
Message-ID: <20110317142418.GB32673@infradead.org>
References: <1299713876-7747-1-git-send-email-david@fromorbit.com>
 <20110310073751.GB25374@infradead.org>
 <20110310224945.GA15097@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110310224945.GA15097@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, npiggin@kernel.dk, xfs@oss.sgi.com

On Fri, Mar 11, 2011 at 09:49:45AM +1100, Dave Chinner wrote:
> > IMHO this should be done by vm_map_ram internally.  If we can't get the
> > core code fixes we can put this in as a last resort.
> 
> OK. The patch was done as part of the triage for this bug:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=27492
> 
> where the vmalloc space on 32 bit systems is getting exhausted. I
> can easily move this flush-and-retry into the vmap code.

Looks like we're not going to make any progress on the VM side for this,
so I think we'll need the XFS variant for 2.6.39.


Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
