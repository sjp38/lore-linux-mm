Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 01AA86B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 08:51:38 -0400 (EDT)
Date: Tue, 20 Oct 2009 13:51:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091020125139.GF11778@csn.ul.ie>
References: <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu> <20091019133146.GB9036@csn.ul.ie> <alpine.DEB.2.00.0910191538450.8526@sebohet.brgvxre.pu> <20091019140957.GE9036@csn.ul.ie> <alpine.DEB.2.00.0910191613580.8526@sebohet.brgvxre.pu> <20091019145954.GH9036@csn.ul.ie> <alpine.DEB.2.00.0910192211230.27123@sebohet.brgvxre.pu> <alpine.DEB.2.00.0910192215450.27123@sebohet.brgvxre.pu> <20091020105746.GD11778@csn.ul.ie> <alpine.DEB.2.00.0910201338530.27123@sebohet.brgvxre.pu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910201338530.27123@sebohet.brgvxre.pu>
Sender: owner-linux-mm@kvack.org
To: Tobias Oetiker <tobi@oetiker.ch>
Cc: Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 20, 2009 at 01:44:50PM +0200, Tobias Oetiker wrote:
> Hi Mel,
> 
> Today Mel Gorman wrote:
> 
> > On Mon, Oct 19, 2009 at 10:17:06PM +0200, Tobias Oetiker wrote:
> 
> > > Oct 19 22:09:52 johan kernel: [11157.121600]  [<ffffffff813ebd42>] skb_copy+0x32/0xa0 [kern.warning]
> > > Oct 19 22:09:52 johan kernel: [11157.121615]  [<ffffffffa07dd33c>] vboxNetFltLinuxPacketHandler+0x5c/0xd0 [vboxnetflt] [kern.warning]
> > > Oct 19 22:09:52 johan kernel: [11157.121620]  [<ffffffff813f2512>] dev_hard_start_xmit+0x142/0x320 [kern.warning]
> >
> > Are the number of failures at least reduced or are they occuring at the
> > same rate?
> 
> not that it would have any statistical significance, but I had 5
> failure (clusters) yesterday morning and 5 this morning ...
> 

Before the patches were applied, how many failures were you seeing in
the morning?

> the failures often show up in groups I saved one on
> http://tobi.oetiker.ch/cluster-2009-10-20-08-31.txt
> 
> > Also, what was the last kernel that worked for you with this
> > configuration?
> 
> that would be 2.6.24 ... I have not upgraded in quite some time.
> But since the io performance of 2.6.31 is about double in my tests
> I thought it would be a good thing todo ...
> 

That significant a different in performance may explain differences in timing
as well. i.e. the allocator is being put under more pressure now than it
was previously as more processes make forward progress.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
