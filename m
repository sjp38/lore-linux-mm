From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Mon, 19 Oct 2009 13:01:15 -0400
Message-ID: <20091019170115.GA4593__2143.15769630975$1255971739$gmane$org@infradead.org>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091014103002.GA5027@csn.ul.ie> <200910141510.11059.elendil@planet.nl> <200910190133.33183.elendil@planet.nl> <20091019140151.GC9036@csn.ul.ie> <20091019161815.GA11487@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A5E766B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 13:01:48 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <20091019161815.GA11487@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Tue, Oct 20, 2009 at 01:18:15AM +0900, Chris Mason wrote:
> Waiting doesn't make it synchronous from the elevator point of view ;)
> If you're using WB_SYNC_NONE, it's a async write.  WB_SYNC_ALL makes it
> a sync write.  I only see WB_SYNC_NONE in vmscan.c, so we should be
> using the async congestion wait.  (the exception is xfs which always
> does async writes).

That's only because those people who did the global sweep did not bother
to convert it or even tell the list about it.  I have a patch in my
QA queue to change it..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
