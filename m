Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id F336C6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 19:28:16 -0400 (EDT)
Received: by pzk4 with SMTP id 4so19526504pzk.6
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 16:28:15 -0700 (PDT)
Date: Mon, 10 Oct 2011 16:28:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memory hotplug: Check if pages are correctly
 reserved on a per-section basis
Message-Id: <20111010162813.7a470ae4.akpm@linux-foundation.org>
In-Reply-To: <20111010232403.GA30513@kroah.com>
References: <20111010071119.GE6418@suse.de>
	<20111010150038.ac161977.akpm@linux-foundation.org>
	<20111010232403.GA30513@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, nfont@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 10 Oct 2011 16:24:03 -0700
Greg KH <greg@kroah.com> wrote:

> On Mon, Oct 10, 2011 at 03:00:38PM -0700, Andrew Morton wrote:
> > On Mon, 10 Oct 2011 08:11:19 +0100
> > Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > It is expected that memory being brought online is PageReserved
> > > similar to what happens when the page allocator is being brought up.
> > > Memory is onlined in "memory blocks" which consist of one or more
> > > sections. Unfortunately, the code that verifies PageReserved is
> > > currently assuming that the memmap backing all these pages is virtually
> > > contiguous which is only the case when CONFIG_SPARSEMEM_VMEMMAP is set.
> > > As a result, memory hot-add is failing on !VMEMMAP configurations
> > > with the message;
> > > 
> > > kernel: section number XXX page number 256 not reserved, was it already online?
> > > 
> > > This patch updates the PageReserved check to lookup struct page once
> > > per section to guarantee the correct struct page is being checked.
> > > 
> > 
> > Nathan's earlier version of this patch is already in linux-next, via
> > Greg.  We should drop the old version and get the new one merged
> > instead.
> 
> Ok, care to send me what exactly needs to be reverted and what needs to
> be added?

Drop

commit 54f23eb7ba7619de85d8edca6e5336bc33072dbd
Author: Nathan Fontenot <nfont@austin.ibm.com>
Date:   Mon Sep 26 10:22:33 2011 -0500

    memory hotplug: Correct page reservation checking

and replace it with start-of-this-thread.

That's assuming that Mel's update passes Nathan's review and testing :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
