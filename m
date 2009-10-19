Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6AB56B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 17:58:52 -0400 (EDT)
Date: Tue, 20 Oct 2009 06:57:57 +0900
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091019215757.GC12570@think>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
 <20091014103002.GA5027@csn.ul.ie>
 <200910141510.11059.elendil@planet.nl>
 <200910190133.33183.elendil@planet.nl>
 <20091019140151.GC9036@csn.ul.ie>
 <20091019161815.GA11487@think>
 <20091019170115.GA4593@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091019170115.GA4593@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 01:01:15PM -0400, Christoph Hellwig wrote:
> On Tue, Oct 20, 2009 at 01:18:15AM +0900, Chris Mason wrote:
> > Waiting doesn't make it synchronous from the elevator point of view ;)
> > If you're using WB_SYNC_NONE, it's a async write.  WB_SYNC_ALL makes it
> > a sync write.  I only see WB_SYNC_NONE in vmscan.c, so we should be
> > using the async congestion wait.  (the exception is xfs which always
> > does async writes).
> 
> That's only because those people who did the global sweep did not bother
> to convert it or even tell the list about it.  I have a patch in my
> QA queue to change it..

Yes, we just didn't realize XFS was missed.  Sorry.  I wasn't trying to
blame xfs for being behind, just mentioning that we've got about 10
different variables here and I'm having a hard time figuring out which
ones to push on.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
