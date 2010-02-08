Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BAE366B0078
	for <linux-mm@kvack.org>; Mon,  8 Feb 2010 07:11:04 -0500 (EST)
Date: Mon, 8 Feb 2010 12:10:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/7] Export unusable free space index via
	/proc/pagetypeinfo
Message-ID: <20100208121048.GB23680@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001281411290.30252@chino.kir.corp.google.com> <20100205102349.GB20412@csn.ul.ie> <alpine.DEB.2.00.1002051336360.12934@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002051336360.12934@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 05, 2010 at 01:40:21PM -0800, David Rientjes wrote:
> On Fri, 5 Feb 2010, Mel Gorman wrote:
> 
> > > > +	/*
> > > > +	 * Index should be a value between 0 and 1. Return a value to 3
> > > > +	 * decimal places.
> > > > +	 *
> > > > +	 * 0 => no fragmentation
> > > > +	 * 1 => high fragmentation
> > > > +	 */
> > > > +	return ((info->free_pages - (info->free_blocks_suitable << order)) * 1000) / info->free_pages;
> > > > +
> > > 
> > > This value is only for userspace consumption via /proc/pagetypeinfo, so 
> > > I'm wondering why it needs to be exported as an index.  Other than a loss 
> > > of precision, wouldn't this be easier to understand (especially when 
> > > coupled with the free page counts already exported) if it were multipled 
> > > by 100 rather than 1000 and shown as a percent of _usable_ free memory at 
> > > each order? 
> > 
> > I find it easier to understand either way, but that's hardly a surprise.
> > The 1000 is because of the loss of precision. I can make it a 100 but I
> > don't think it makes much of a difference.
> > 
> 
> This suggestion was coupled with the subsequent note that there is no 
> documentation of what "unusuable free space index" is, except by the 
> implementation itself.  Since the value isn't used by the kernel,  I think 
> exporting the value as a percent would be easier understood by the user 
> without looking up the semantics.  I don't have strong feelings either 
> way, however.
> 

I'm writing documentation. I'm keeping with the 1000 value because a) I
like the precision and b) the fragmentation index is not related to
percentages and I think having one as a percentage and the other as an
index would cause confusion. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
