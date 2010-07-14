Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F7B96201FE
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 22:15:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6E2FVaP008465
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 14 Jul 2010 11:15:31 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F49945DE52
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 11:15:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DED9545DE4F
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 11:15:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B27FD1DB8049
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 11:15:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 62C641DB8057
	for <linux-mm@kvack.org>; Wed, 14 Jul 2010 11:15:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2 1/2] vmscan: don't subtraction of unsined
In-Reply-To: <alpine.DEB.2.00.1007132047001.14067@router.home>
References: <20100713182918.EA67.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1007132047001.14067@router.home>
Message-Id: <20100714110614.EA7B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 14 Jul 2010 11:15:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 13 Jul 2010, KOSAKI Motohiro wrote:
> 
> > Christoph, Can we hear your opinion about to add new branch in slab-free path?
> > I think this is ok, because reclaim makes a lot of cache miss then branch
> > mistaken is relatively minor penalty. thought?
> 
> Its on the slow path so I would think that should be okay. But is this
> really necessary? Working with the per zone slab reclaim counters is not
> enough? We are adding counter after counter that have similar purposes and
> the handling gets more complex.
> 
> Maybe we can get rid of the code in the slabs instead by just relying on
> the difference of the zone counters?

Okey, I agree. I'm pending this work at once. and I'll (probably) resume it
after Nick's work merged.

Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
