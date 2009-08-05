Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A53736B005D
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:26:27 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n759QY0w030839
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 5 Aug 2009 18:26:34 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD76845DE6E
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 18:26:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BBD4245DE60
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 18:26:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 93055E08003
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 18:26:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 47D1D1DB8037
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 18:26:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] tracing, mm: Add trace events for anti-fragmentation falling back to other migratetypes
In-Reply-To: <1249409546-6343-3-git-send-email-mel@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20090805182518.5BD0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  5 Aug 2009 18:26:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Fragmentation avoidance depends on being able to use free pages from
> lists of the appropriate migrate type. In the event this is not
> possible, __rmqueue_fallback() selects a different list and in some
> circumstances change the migratetype of the pageblock. Simplistically,
> the more times this event occurs, the more likely that fragmentation
> will be a problem later for hugepage allocation at least but there are
> other considerations such as the order of page being split to satisfy
> the allocation.
> 
> This patch adds a trace event for __rmqueue_fallback() that reports what
> page is being used for the fallback, the orders of relevant pages, the
> desired migratetype and the migratetype of the lists being used, whether
> the pageblock changed type and whether this event is important with
> respect to fragmentation avoidance or not. This information can be used
> to help analyse fragmentation avoidance and help decide whether
> min_free_kbytes should be increased or not.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>

Looks good to me.
but I don't put my reviewed-by because I am not so familiar this area.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
