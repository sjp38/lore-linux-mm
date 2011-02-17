Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B743B8D003A
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 12:52:47 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 070B23EE0B3
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 02:52:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D940845DE52
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 02:52:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDB5345DE4D
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 02:52:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE7C4EF8006
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 02:52:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AD4FEF8003
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 02:52:34 +0900 (JST)
Date: Fri, 18 Feb 2011 02:46:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/8] mm: Remove i_mmap_mutex lockbreak
Message-Id: <20110218024603.2089221d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110217170854.766930171@chello.nl>
References: <20110217170520.229881980@chello.nl>
	<20110217170854.766930171@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>

On Thu, 17 Feb 2011 18:05:22 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Hugh says:
>  "The only significant loser, I think, would be page reclaim (when
>   concurrent with truncation): could spin for a long time waiting for
>   the i_mmap_mutex it expects would soon be dropped? "
> 
> Counter points:
>  - cpu contention makes the spin stop (need_resched())
>  - zap pages should be freeing pages at a higher rate than reclaim
>    ever can
>  - shouldn't hold up reclaim more than lock_page() would
> 
> I think the simplification of the truncate code is definately worth
> it.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Maybe I have to improve batched-uncharge in memcg, whose work depends
on ZAP_BLOCK_SIZE....but the zap routine seems cleaner.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
