Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A66D08D0004
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 04:01:05 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9S8122q021023
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 28 Oct 2010 17:01:03 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 76F7645DE4F
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 17:01:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4481A45DE52
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 17:01:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 228221DB804D
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 17:01:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93761E38001
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 17:00:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim condition
In-Reply-To: <20101027180333.GE29304@random.random>
References: <20101027171643.GA4896@csn.ul.ie> <20101027180333.GE29304@random.random>
Message-Id: <20101028162522.B0B5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 28 Oct 2010 17:00:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi

> My tree uses compaction in a fine way inside kswapd too and tons of
> systems are running without lumpy and floods of order 9 allocations
> with only compaction (in direct reclaim and kswapd) without the
> slighest problem. Furthermore I extended compaction for all
> allocations not just that PAGE_ALLOC_COSTLY_ORDER (maybe I already
> removed all PAGE_ALLOC_COSTLY_ORDER checks?). There's no good reason
> not to use compaction for every allocation including 1,2,3, and things
> works fine this way.

Interesting. I parsed this you have compaction improvement. If so,
can you please post them? Generically, 1) improve the feature 2) remove
unused one is safety order. In the other hand, reverse order seems to has
regression risk.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
