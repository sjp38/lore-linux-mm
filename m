Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 567BD6B007B
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 05:29:52 -0500 (EST)
Date: Mon, 1 Feb 2010 10:29:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: PROBLEM: kernel BUG at mm/page_alloc.c:775
Message-ID: <20100201102935.GA21053@csn.ul.ie>
References: <201001092232.21841.mb@emeraldcity.de> <20100118120315.GD7499@csn.ul.ie> <201001210110.18569.mb@emeraldcity.de> <201001292302.04105.mb@emeraldcity.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201001292302.04105.mb@emeraldcity.de>
Sender: owner-linux-mm@kvack.org
To: Michail Bachmann <mb@emeraldcity.de>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 29, 2010 at 11:01:57PM +0100, Michail Bachmann wrote:
> > > On Tue, Jan 12, 2010 at 03:25:23PM -0600, Christoph Lameter wrote:
> > > > On Sat, 9 Jan 2010, Michail Bachmann wrote:
> > > > > [   48.505381] kernel BUG at mm/page_alloc.c:775!
> > > >
> > > > Somehow nodes got mixed up or the lookup tables for pages / zones are
> > > > not giving the right node numbers.
> > >
> > > Agreed. On this type of machine, I'm not sure how that could happen
> > > short of struct page information being corrupted. The range should
> > > always be aligned to a pageblock boundary and I cannot see how that
> > > would cross a zone boundary on this machine.
> > >
> > > Does this machine pass memtest?
> > 
> > I ran one pass with memtest86 without errors before posting this bug, but I
> > can let it run "all tests" for a while just to be sure it is not caused by
> > broken hw.
> 
> Please disregard this bug report. After running memtest for more than 10 hours 
> it found a memory error.

I'm sorry to hear it but at least the source of the bug is known.

> The funny thing is, linux found it much faster...
> 

It could be that your power supply is slightly too inefficient and the
errors only occur when all cores are active or all disks - something
Linux might do easily where as memtest does not necessarily stress the
machine enough for the power drop to happen.

> Thanks for your time.
> 

Thanks for testing and getting back to us.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
