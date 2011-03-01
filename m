Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3518D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 23:12:02 -0500 (EST)
Received: by iyf13 with SMTP id 13so4733549iyf.14
        for <linux-mm@kvack.org>; Mon, 28 Feb 2011 20:11:58 -0800 (PST)
Date: Tue, 1 Mar 2011 13:11:46 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are
 disabled while isolating pages for migration
Message-ID: <20110301041146.GA2107@barrios-desktop>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
 <1298664299-10270-3-git-send-email-mel@csn.ul.ie>
 <20110228111746.34f3f3e0.kamezawa.hiroyu@jp.fujitsu.com>
 <20110228054818.GF22700@random.random>
 <20110228145402.65e6f200.kamezawa.hiroyu@jp.fujitsu.com>
 <20110228092814.GC9548@csn.ul.ie>
 <20110228184230.7c2eefb7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110228101827.GE9548@csn.ul.ie>
 <20110301084209.2cfbd063.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110301084209.2cfbd063.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 01, 2011 at 08:42:09AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 28 Feb 2011 10:18:27 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > > BTW, can't we drop disable_irq() from all lru_lock related codes ?
> > > 
> > 
> > I don't think so - at least not right now. Some LRU operations such as LRU
> > pagevec draining are run from IPI which is running from an interrupt so
> > minimally spin_lock_irq is necessary.
> > 
> 
> pagevec draining is done by workqueue(schedule_on_each_cpu()). 
> I think only racy case is just lru rotation after writeback.

put_page still need irq disable.


> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
