Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E4D306B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 00:59:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D4xDp1021944
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Jul 2010 13:59:13 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 41C2345DE58
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:59:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19B6545DE4E
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:59:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E45FF1DB8054
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:59:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DD2C1DB8057
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:59:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: stop meaningless loop iteration when no reclaimable slab
In-Reply-To: <alpine.DEB.2.00.1007090859560.30663@router.home>
References: <20100709191308.FA25.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1007090859560.30663@router.home>
Message-Id: <20100713135817.EA4F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Jul 2010 13:59:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 9 Jul 2010, KOSAKI Motohiro wrote:
> 
> > If number of reclaimable slabs are zero, shrink_icache_memory() and
> > shrink_dcache_memory() return 0. but strangely shrink_slab() ignore
> > it and continue meaningless loop iteration.
> 
> There is also a per zone/node/global counter SLAB_RECLAIM_ACCOUNT that
> could be used to determine if its worth looking at things at all. I saw
> some effort going into making the shrinkers zone aware. If so then we may
> be able to avoid scanning slabs.

Yup.
After to merge nick's effort, we can makes more imrovement. I bet :)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
