Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 46CD16B007B
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 04:24:55 -0500 (EST)
Date: Fri, 6 Nov 2009 09:24:47 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Message-ID: <20091106092447.GC25926@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <20091106060323.GA5528@yumi.tdiedrich.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091106060323.GA5528@yumi.tdiedrich.de>
Sender: owner-linux-mm@kvack.org
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 06, 2009 at 07:03:23AM +0100, Tobias Diedrich wrote:
> Mel Gorman wrote:
> > [No BZ ID] Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
> > 	This apparently is easily reproducible, particular in comparison to
> > 	the other reports. The point of greatest interest is that this is
> > 	order-0 GFP_ATOMIC failures. Sven, I'm hoping that you in particular
> > 	will be able to follow the tests below as you are the most likely
> > 	person to have an easily reproducible situation.
> 
> I've also seen order-0 failures on 2.6.31.5:
> Note that this is with a one process hogging and mlocking memory and
> min_free_kbytes reduced to 100 to reproduce the problem more easily.
> 

Is that a vanilla, with patches 1-3 applied or both?

> I tried bisecting the issue, but in the end without memory pressure
> I can't reproduce it reliably and with the above mentioned pressure
> I get allocation failures even on 2.6.30.o
> 

To be honest, it's not entirely unexpected with min_free_kbytes set that
low. The system should cope with a certain amount of pressure but with
pressure and a low min_free_kbytes, the system will simply be reacting
too late to free memory in the non-atomic paths.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
