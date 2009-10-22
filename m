Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 342C66B007B
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 17:33:59 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so2656346fga.8
        for <linux-mm@kvack.org>; Thu, 22 Oct 2009 14:33:57 -0700 (PDT)
Date: Thu, 22 Oct 2009 23:33:53 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH] SLUB: Don't drop __GFP_NOFAIL completely from
	allocate_slab() (was: Re: [Bug #14265] ifconfig: page allocation
	failure. order:5,ode:0x8020 w/ e100)
Message-ID: <20091022213353.GA7137@bizet.domek.prywatny>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <COE24pZSBH.A.rP.2MTxKB@chimera> <20091021200442.GA2987@bizet.domek.prywatny> <alpine.DEB.2.00.0910211400140.20010@chino.kir.corp.google.com> <20091021212034.GB2987@bizet.domek.prywatny> <20091022102014.GL11778@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091022102014.GL11778@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, David Rientjes <rientjes@google.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com, Tobias Oetiker <tobi@oetiker.ch>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 22, 2009 at 11:20:14AM +0100, Mel Gorman wrote:
> On Wed, Oct 21, 2009 at 11:20:34PM +0200, Karol Lewandowski wrote:
> > > Note: slub isn't going to be a culprit in order 5 allocation failures 
> > > since they have kmalloc passthrough to the page allocator.
> > 
> > However, it might change fragmentation somewhat I guess.  This might
> > make problem more/less visible.
> > 
> 
> Did you have CONFIG_KMEMCHECK set by any chance?

No, kmemcheck (and kmemleak) was always disabled.

It's likely that's possible to trigger allocation failures with slab,
I just haven't been successful at it.  Lack of good testcase is really
problem here -- even if I can't trigger failures I can never be sure
that these wont appear in some strange moment.

BTW I'll test your patches (from another thread) shortly.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
