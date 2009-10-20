Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2C84B6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 10:14:24 -0400 (EDT)
Date: Tue, 20 Oct 2009 15:14:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091020141423.GH11778@csn.ul.ie>
References: <alpine.DEB.2.00.0910191613580.8526@sebohet.brgvxre.pu> <20091019145954.GH9036@csn.ul.ie> <alpine.DEB.2.00.0910192211230.27123@sebohet.brgvxre.pu> <alpine.DEB.2.00.0910192215450.27123@sebohet.brgvxre.pu> <20091020105746.GD11778@csn.ul.ie> <alpine.DEB.2.00.0910201338530.27123@sebohet.brgvxre.pu> <20091020125139.GF11778@csn.ul.ie> <alpine.DEB.2.00.0910201456540.27618@sebohet.brgvxre.pu> <20091020133957.GG11778@csn.ul.ie> <alpine.DEB.2.00.0910201545510.27618@sebohet.brgvxre.pu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910201545510.27618@sebohet.brgvxre.pu>
Sender: owner-linux-mm@kvack.org
To: Tobias Oetiker <tobi@oetiker.ch>
Cc: Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 20, 2009 at 03:50:12PM +0200, Tobias Oetiker wrote:
> Hi Mel,
> 
> Today Mel Gorman wrote:
> 
> > On Tue, Oct 20, 2009 at 02:58:53PM +0200, Tobias Oetiker wrote:
> > > you are saing that the problem might be even older ?
> > >
> > > we do have 8GB ram and 16 GB swap, so it should not fail to allocate all that
> > > often
> > >
> > > top - 14:58:34 up 19:54,  6 users,  load average: 2.09, 1.94, 1.97
> > > Tasks: 451 total,   1 running, 449 sleeping,   0 stopped,   1 zombie
> > > Cpu(s):  3.5%us, 15.5%sy,  2.0%ni, 72.2%id,  6.5%wa,  0.1%hi,  0.3%si,  0.0%st
> > > Mem:   8198504k total,  7599132k used,   599372k free,  1212636k buffers
> > > Swap: 16777208k total,    83568k used, 16693640k free,   610136k cached
> > >
> >
> > High-order atomic allocations of the type you are trying at that frequency
> > were always a very long shot. The most likely outcome is that something
> > has changed that means a burst of allocations trigger an allocation failure
> > where as before processes would delay long enough for the system not to notice.
> >
> > 1. Have MTU settings changed?
> 
> no not to my knowledge
> 
> > 2. As order-5 allocations are required to succeed, I'm surprised in a
> >    sense that there are only 5 failures because it implies the machine is
> >    actually recovering and continueing on as normal. Can you think of what
> >    happens in the morning that causes a burst of allocations to occur?
> 
> the burts occur all day while the machine is in use ... its just
> that I was  writing this at noon so only the morning had passed. So
> I compared things to the day before ...
> 

Over the course of a day, how many would you see? By and large, it seems
that the problem yourself and Frans are similar except his is a lot more
severe.

> > 3. Other than the failures, have you noticed any other problems with the
> >    machine or does it continue along happily?
> 
> The machine seems to be fine.
> 
> > 4. Does the following patch help by any chance?
> 
> should I try this on vanilla 2.6.31.4 or ontop of your previous
> patch?
> 

Try on top of vanilla 2.6.31.4 first plase and if failures still occur,
then on top of the previous patch.

> we are running virtualbox 3.0.8 on this machine, virtualbox is using
> the physical network interface in bridge mode access the network.
> Could this have something todo with the problem ?
> 

I do not know for sure. I'm assuming the configuration is the same on
both kernels so it's unlikely to be the issue.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
