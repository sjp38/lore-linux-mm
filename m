Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 088FF8D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 00:48:57 -0500 (EST)
Date: Mon, 28 Feb 2011 06:48:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are
 disabled while isolating pages for migration
Message-ID: <20110228054818.GF22700@random.random>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
 <1298664299-10270-3-git-send-email-mel@csn.ul.ie>
 <20110228111746.34f3f3e0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110228111746.34f3f3e0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Feb 28, 2011 at 11:17:46AM +0900, KAMEZAWA Hiroyuki wrote:
> BTW, I forget why we always take zone->lru_lock with IRQ disabled....

To decrease lock contention in SMP to deliver overall better
performance (not sure how much it helps though). It was supposed to be
hold for a very short time (PAGEVEC_SIZE) to avoid giving irq latency
problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
