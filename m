Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 927A56B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 19:24:22 -0400 (EDT)
Date: Mon, 10 Oct 2011 16:24:03 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] mm: memory hotplug: Check if pages are correctly
 reserved on a per-section basis
Message-ID: <20111010232403.GA30513@kroah.com>
References: <20111010071119.GE6418@suse.de>
 <20111010150038.ac161977.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111010150038.ac161977.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, nfont@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, Oct 10, 2011 at 03:00:38PM -0700, Andrew Morton wrote:
> On Mon, 10 Oct 2011 08:11:19 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > It is expected that memory being brought online is PageReserved
> > similar to what happens when the page allocator is being brought up.
> > Memory is onlined in "memory blocks" which consist of one or more
> > sections. Unfortunately, the code that verifies PageReserved is
> > currently assuming that the memmap backing all these pages is virtually
> > contiguous which is only the case when CONFIG_SPARSEMEM_VMEMMAP is set.
> > As a result, memory hot-add is failing on !VMEMMAP configurations
> > with the message;
> > 
> > kernel: section number XXX page number 256 not reserved, was it already online?
> > 
> > This patch updates the PageReserved check to lookup struct page once
> > per section to guarantee the correct struct page is being checked.
> > 
> 
> Nathan's earlier version of this patch is already in linux-next, via
> Greg.  We should drop the old version and get the new one merged
> instead.

Ok, care to send me what exactly needs to be reverted and what needs to
be added?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
