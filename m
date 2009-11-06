Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBF0C6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 06:15:19 -0500 (EST)
Date: Fri, 6 Nov 2009 12:15:14 +0100
From: Tobias Diedrich <ranma@tdiedrich.de>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Message-ID: <20091106111514.GB5387@yumi.tdiedrich.de>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091106060323.GA5528@yumi.tdiedrich.de> <20091106092447.GC25926@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091106092447.GC25926@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Fri, Nov 06, 2009 at 07:03:23AM +0100, Tobias Diedrich wrote:
> > Mel Gorman wrote:
> > > [No BZ ID] Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
> > > 	This apparently is easily reproducible, particular in comparison to
> > > 	the other reports. The point of greatest interest is that this is
> > > 	order-0 GFP_ATOMIC failures. Sven, I'm hoping that you in particular
> > > 	will be able to follow the tests below as you are the most likely
> > > 	person to have an easily reproducible situation.
> > 
> > I've also seen order-0 failures on 2.6.31.5:
> > Note that this is with a one process hogging and mlocking memory and
> > min_free_kbytes reduced to 100 to reproduce the problem more easily.
> > 
> 
> Is that a vanilla, with patches 1-3 applied or both?
That was on vanilla 2.6.31.5.

I tried 2.6.31.5 before with patches 1+2 and netconsole enabled and
still got the order-1 failures (apparently I get order-1 failures
with netconsole and order-0 failures without).

> > I tried bisecting the issue, but in the end without memory pressure
> > I can't reproduce it reliably and with the above mentioned pressure
> > I get allocation failures even on 2.6.30.o
> 
> To be honest, it's not entirely unexpected with min_free_kbytes set that
> low. The system should cope with a certain amount of pressure but with
> pressure and a low min_free_kbytes, the system will simply be reacting
> too late to free memory in the non-atomic paths.
Maybe I should try again on 2.6.30 without netconsole und try
increasing min_free_kbytes until the allocation failures
disappear and try to bisect again with that setting...

-- 
Tobias						PGP: http://8ef7ddba.uguu.de

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
