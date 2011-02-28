Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 504778D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:48:37 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6CA523EE0AE
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 08:48:32 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55B722AEA81
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 08:48:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D71845DE61
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 08:48:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 312511DB802C
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 08:48:32 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F21951DB803A
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 08:48:31 +0900 (JST)
Date: Tue, 1 Mar 2011 08:42:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are disabled
 while isolating pages for migration
Message-Id: <20110301084209.2cfbd063.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110228101827.GE9548@csn.ul.ie>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
	<1298664299-10270-3-git-send-email-mel@csn.ul.ie>
	<20110228111746.34f3f3e0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228054818.GF22700@random.random>
	<20110228145402.65e6f200.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228092814.GC9548@csn.ul.ie>
	<20110228184230.7c2eefb7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228101827.GE9548@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 28 Feb 2011 10:18:27 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> > BTW, can't we drop disable_irq() from all lru_lock related codes ?
> > 
> 
> I don't think so - at least not right now. Some LRU operations such as LRU
> pagevec draining are run from IPI which is running from an interrupt so
> minimally spin_lock_irq is necessary.
> 

pagevec draining is done by workqueue(schedule_on_each_cpu()). 
I think only racy case is just lru rotation after writeback.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
