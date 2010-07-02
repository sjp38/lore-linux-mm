Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4E34F6B01BA
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 02:36:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o626aKBp005100
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 2 Jul 2010 15:36:20 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5471B45DE61
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:36:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 326C445DE51
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:36:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A62C1DB803C
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:36:20 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B5CE01DB803E
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:36:19 +0900 (JST)
Date: Fri, 2 Jul 2010 15:31:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] fs,xfs: Allow kswapd to writeback pages
Message-Id: <20100702153143.44c5fec8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100702152643.36019b4e.kamezawa.hiroyu@jp.fujitsu.com>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
	<1277811288-5195-15-git-send-email-mel@csn.ul.ie>
	<20100629123722.GA725@infradead.org>
	<20100629125143.GB31561@csn.ul.ie>
	<20100630091411.49f92cff.kamezawa.hiroyu@jp.fujitsu.com>
	<20100701103032.GG31741@csn.ul.ie>
	<20100702152643.36019b4e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Jul 2010 15:26:43 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > I see the direction you are thinking of but I have big concerns about clean
> > pages getting delayed for too long on the LRU_CLEANING pages before kswapd
> > puts them back in the right place. I think a safer direction would be for
> > memcg people to investigate Andrea's "switch stack" suggestion.
> > 
> Hmm, I may have to consider that. My concern is that IRQ's switch-stack works
> well just because no-task-switch in IRQ routine. (I'm sorry if I misunderstand.)
> 
Ok, I'll think about this 1st.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
