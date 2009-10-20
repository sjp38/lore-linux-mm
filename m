Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 444FC6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 07:44:53 -0400 (EDT)
Date: Tue, 20 Oct 2009 13:44:50 +0200 (CEST)
From: Tobias Oetiker <tobi@oetiker.ch>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
In-Reply-To: <20091020105746.GD11778@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0910201338530.27123@sebohet.brgvxre.pu>
References: <1255912562.6824.9.camel@penberg-laptop> <200910190444.55867.elendil@planet.nl> <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu> <20091019133146.GB9036@csn.ul.ie> <alpine.DEB.2.00.0910191538450.8526@sebohet.brgvxre.pu> <20091019140957.GE9036@csn.ul.ie>
 <alpine.DEB.2.00.0910191613580.8526@sebohet.brgvxre.pu> <20091019145954.GH9036@csn.ul.ie> <alpine.DEB.2.00.0910192211230.27123@sebohet.brgvxre.pu> <alpine.DEB.2.00.0910192215450.27123@sebohet.brgvxre.pu> <20091020105746.GD11778@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

Hi Mel,

Today Mel Gorman wrote:

> On Mon, Oct 19, 2009 at 10:17:06PM +0200, Tobias Oetiker wrote:

> > Oct 19 22:09:52 johan kernel: [11157.121600]  [<ffffffff813ebd42>] skb_copy+0x32/0xa0 [kern.warning]
> > Oct 19 22:09:52 johan kernel: [11157.121615]  [<ffffffffa07dd33c>] vboxNetFltLinuxPacketHandler+0x5c/0xd0 [vboxnetflt] [kern.warning]
> > Oct 19 22:09:52 johan kernel: [11157.121620]  [<ffffffff813f2512>] dev_hard_start_xmit+0x142/0x320 [kern.warning]
>
> Are the number of failures at least reduced or are they occuring at the
> same rate?

not that it would have any statistical significance, but I had 5
failure (clusters) yesterday morning and 5 this morning ...

the failures often show up in groups I saved one on
http://tobi.oetiker.ch/cluster-2009-10-20-08-31.txt

> Also, what was the last kernel that worked for you with this
> configuration?

that would be 2.6.24 ... I have not upgraded in quite some time.
But since the io performance of 2.6.31 is about double in my tests
I thought it would be a good thing todo ...

cheers
tobi

> Thanks
>
> > Oct 19 22:09:52 johan kernel: [11157.121632]  [<ffffffff8140a2c1>] __qdisc_run+0x1a1/0x230 [kern.warning]
> > Oct 19 22:09:52 johan kernel: [11157.121637]  [<ffffffff813f41e0>] dev_queue_xmit+0x2b0/0x3a0 [kern.warning]
> > Oct 19 22:09:52 johan kernel: [11157.121642]  [<ffffffff8142349b>] ip_finish_output+0x11b/0x2f0 [kern.warning]
> > Oct 19 22:09:52 johan kernel: [11157.121646]  [<ffffffff814236f9>] ip_output+0x89/0xd0 [kern.warning]
> > Oct 19 22:09:52 johan kernel: [11157.121650]  [<ffffffff81422710>] ip_local_out+0x20/0x30 [kern.warning]
> > Oct 19 22:09:52 johan kernel: [11157.121654]  [<ffffffff81422ffb>] ip_queue_xmit+0x22b/0x3f0 [kern.warning]
> >
>
>

-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
