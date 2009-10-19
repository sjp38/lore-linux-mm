Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1B06C6B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 10:06:18 -0400 (EDT)
Date: Mon, 19 Oct 2009 15:06:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091019140619.GD9036@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910190133.33183.elendil@planet.nl> <1255912562.6824.9.camel@penberg-laptop> <200910190444.55867.elendil@planet.nl> <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu> <1255946051.5941.2.camel@penberg-laptop> <20091019140145.GA4222@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091019140145.GA4222@bizet.domek.prywatny>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Tobi Oetiker <tobi@oetiker.ch>, Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 04:01:45PM +0200, Karol Lewandowski wrote:
> On Mon, Oct 19, 2009 at 12:54:11PM +0300, Pekka Enberg wrote:
> > On Mon, 2009-10-19 at 11:49 +0200, Tobi Oetiker wrote:
> > > I have updated a fileserver to 2.6.31 today and I see page
> > > allocation failures from several parts of the system ... mostly nfs though ... (it is a nfs server).
> > > So I guess the problem must be quite generic:
> > 
> > Yup, it almost certainly is. Does this patch help?
> > 
> > http://lkml.org/lkml/2009/10/16/89
> 
> This patch seems to help in some cases.  Before applying this patch I
> was able to trigger alloc failures on different machine by booting
> kernel with "mem=256MB" and doing:
> 
>   $ gitk on-full-tree &
>   # rmmod e100
>   ... wait for few MBs in swap
>   # modprobe e100; ifup --force ethX
> 
> So here this patch helped -- with it, I was unable to trigger page
> allocation failures (testing was short, tough).  However, as I said
> here[1], I applied both of Mel's patches (including this one) and that
> didn't help my orginal issue (failures after suspend).
> 
> [1] http://lkml.org/lkml/2009/10/17/109
> 

Can you test with my kswapd patch applied and commits 373c0a7e,8aa7e847
reverted please?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
