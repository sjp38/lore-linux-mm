Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 72D7F6B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 17:28:16 -0500 (EST)
Date: Thu, 11 Feb 2010 14:27:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: suppress pfn range output for zones without pages
Message-Id: <20100211142734.24df7447.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1002111324280.5705@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002110129280.3069@chino.kir.corp.google.com>
	<20100211122507.GA32292@csn.ul.ie>
	<alpine.DEB.2.00.1002111324280.5705@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010 13:26:37 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 11 Feb 2010, Mel Gorman wrote:
> 
> > > free_area_init_nodes() emits pfn ranges for all zones on the system.
> > > There may be no pages on a higher zone, however, due to memory
> > > limitations or the use of the mem= kernel parameter.  For example:
> > > 
> > > Zone PFN ranges:
> > >   DMA      0x00000001 -> 0x00001000
> > >   DMA32    0x00001000 -> 0x00100000
> > >   Normal   0x00100000 -> 0x00100000
> > > 
> > > The implementation copies the previous zone's highest pfn, if any, as the
> > > next zone's lowest pfn.  If its highest pfn is then greater than the
> > > amount of addressable memory, the upper memory limit is used instead.
> > > Thus, both the lowest and highest possible pfn for higher zones without
> > > memory may be the same.
> > > 
> > > The output is now suppressed for zones that do not have a valid pfn
> > > range.
> > > 
> > 
> > I see no problem with the patch. Was it a major problem or just
> > confusing?
> > 
> 
> It was just confusing, I don't think anybody would be parsing the kernel 
> log for this specifically to determine whether ZONE_NORMAL exists :)
> 
> > > Cc: Mel Gorman <mel@csn.ul.ie>
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> > 
> 
> Thanks!

I ducked this patch because Christoph's complaint sounded reasonable -
by suppressing this output we're removing information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
