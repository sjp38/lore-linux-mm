Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 632B68D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 01:00:37 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A4D473EE0CB
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 15:00:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D9AA45DE55
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 15:00:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 631E645DE56
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 15:00:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 566F2E38002
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 15:00:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E578E08001
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 15:00:33 +0900 (JST)
Date: Mon, 28 Feb 2011 14:54:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are disabled
 while isolating pages for migration
Message-Id: <20110228145402.65e6f200.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110228054818.GF22700@random.random>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
	<1298664299-10270-3-git-send-email-mel@csn.ul.ie>
	<20110228111746.34f3f3e0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110228054818.GF22700@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 28 Feb 2011 06:48:18 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Mon, Feb 28, 2011 at 11:17:46AM +0900, KAMEZAWA Hiroyuki wrote:
> > BTW, I forget why we always take zone->lru_lock with IRQ disabled....
> 
> To decrease lock contention in SMP to deliver overall better
> performance (not sure how much it helps though). It was supposed to be
> hold for a very short time (PAGEVEC_SIZE) to avoid giving irq latency
> problems.
> 

memory hotplug uses MIGRATE_ISOLATED migrate types for scanning pfn range
without lru_lock. I wonder whether we can make use of it (the function
which memory hotplug may need rework for the compaction but  migrate_type can
be used, I think).

Hmm.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
