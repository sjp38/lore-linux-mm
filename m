Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m933fjN8030169
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 3 Oct 2008 12:41:45 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CA8C2AC026
	for <linux-mm@kvack.org>; Fri,  3 Oct 2008 12:41:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 453DA12C045
	for <linux-mm@kvack.org>; Fri,  3 Oct 2008 12:41:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 290551DB803A
	for <linux-mm@kvack.org>; Fri,  3 Oct 2008 12:41:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D288A1DB803B
	for <linux-mm@kvack.org>; Fri,  3 Oct 2008 12:41:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for	allocation by the reclaimer
In-Reply-To: <48E4F6EC.7010500@linux-foundation.org>
References: <20081002143508.GE11089@brain> <48E4F6EC.7010500@linux-foundation.org>
Message-Id: <20081003123545.EF5B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  3 Oct 2008 12:41:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Cristoph,

> >> At the beginning of reclaim just flush all pcp pages and then do not allow pcp
> >> refills again until reclaim is finished?
> > 
> > Not entirely, some pages could get trapped there for sure.  But it is
> > parallel allocations we are trying to guard against.  Plus we already flush
> > the pcp during reclaim for higher orders.
> 
> So we just would need to forbid refilling the pcp.
> 
> Parallel allocations are less a problem if the freed order 0 pages get merged
> immediately into the order 1 freelist. Of course that will only work 50% of
> the time but it will have a similar effect to this patch.

Ah, Right.
Could we hear why you like pcp disabling than Andy's patch?

Honestly, I think pcp has some problem.
But I avoid to change pcp because I don't understand its design.

Maybe, we should discuss currect pcp behavior?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
