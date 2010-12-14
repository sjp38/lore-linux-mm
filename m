Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 891636B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 18:56:51 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBENun4n029935
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Dec 2010 08:56:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13A8345DE4D
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 08:56:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EC4D345DE5D
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 08:56:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D544FE18001
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 08:56:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A548E08001
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 08:56:48 +0900 (JST)
Date: Wed, 15 Dec 2010 08:50:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv7 08/10] mm: cma: Contiguous Memory Allocator added
Message-Id: <20101215085047.251778be.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <87zks8fyb0.fsf@erwin.mina86.com>
References: <cover.1292004520.git.m.nazarewicz@samsung.com>
	<fc8aa07ac71d554ba10af4943fdb05197c681fa2.1292004520.git.m.nazarewicz@samsung.com>
	<20101214102401.37bf812d.kamezawa.hiroyu@jp.fujitsu.com>
	<87zks8fyb0.fsf@erwin.mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Michal Nazarewicz <m.nazarewicz@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, BooJin Kim <boojin.kim@samsung.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>
List-ID: <linux-mm.kvack.org>

On Tue, 14 Dec 2010 11:23:15 +0100
Michal Nazarewicz <mina86@mina86.com> wrote:

> > Hmm, it seems __cm_alloc() and __cm_migrate() has no special codes for CMA.
> > I'd like reuse this for my own contig page allocator.
> > So, could you make these function be more generic (name) ?
> > as
> > 	__alloc_range(start, size, mirate_type);
> >
> > Then, what I have to do is only to add "search range" functions.
> 
> Sure thing.  I'll post it tomorrow or Friday. How about
> alloc_contig_range() maybe?
> 

That sounds great. Thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
