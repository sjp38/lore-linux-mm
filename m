Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7AC6B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 16:40:29 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o15LeTH3026188
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 21:40:29 GMT
Received: from pzk11 (pzk11.prod.google.com [10.243.19.139])
	by kpbe17.cbf.corp.google.com with ESMTP id o15LeRck024295
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 13:40:27 -0800
Received: by pzk11 with SMTP id 11so1003880pzk.32
        for <linux-mm@kvack.org>; Fri, 05 Feb 2010 13:40:27 -0800 (PST)
Date: Fri, 5 Feb 2010 13:40:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/7] Export unusable free space index via
 /proc/pagetypeinfo
In-Reply-To: <20100205102349.GB20412@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1002051336360.12934@chino.kir.corp.google.com>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-3-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001281411290.30252@chino.kir.corp.google.com> <20100205102349.GB20412@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Feb 2010, Mel Gorman wrote:

> > > +	/*
> > > +	 * Index should be a value between 0 and 1. Return a value to 3
> > > +	 * decimal places.
> > > +	 *
> > > +	 * 0 => no fragmentation
> > > +	 * 1 => high fragmentation
> > > +	 */
> > > +	return ((info->free_pages - (info->free_blocks_suitable << order)) * 1000) / info->free_pages;
> > > +
> > 
> > This value is only for userspace consumption via /proc/pagetypeinfo, so 
> > I'm wondering why it needs to be exported as an index.  Other than a loss 
> > of precision, wouldn't this be easier to understand (especially when 
> > coupled with the free page counts already exported) if it were multipled 
> > by 100 rather than 1000 and shown as a percent of _usable_ free memory at 
> > each order? 
> 
> I find it easier to understand either way, but that's hardly a surprise.
> The 1000 is because of the loss of precision. I can make it a 100 but I
> don't think it makes much of a difference.
> 

This suggestion was coupled with the subsequent note that there is no 
documentation of what "unusuable free space index" is, except by the 
implementation itself.  Since the value isn't used by the kernel,  I think 
exporting the value as a percent would be easier understood by the user 
without looking up the semantics.  I don't have strong feelings either 
way, however.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
