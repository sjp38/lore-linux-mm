Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D92F46B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 21:46:27 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 262E13EE0BD
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:46:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 098FC45DE6D
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:46:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DEEC345DE68
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:46:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CE3381DB802C
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:46:24 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F2A11DB803A
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 11:46:24 +0900 (JST)
Date: Mon, 7 Nov 2011 11:45:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc 3/3] mm: vmscan: revert file list boost on lru addition
Message-Id: <20111107114520.33050d75.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111102163247.GJ19965@redhat.com>
References: <20110808110658.31053.55013.stgit@localhost6>
	<CAOJsxLF909NRC2r6RL+hm1ARve+3mA6UM_CY9epJaauyqJTG8w@mail.gmail.com>
	<4E3FD403.6000400@parallels.com>
	<20111102163056.GG19965@redhat.com>
	<20111102163247.GJ19965@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@parallels.com>, Pekka Enberg <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Gene Heskett <gene.heskett@gmail.com>

On Wed, 2 Nov 2011 17:32:47 +0100
Johannes Weiner <jweiner@redhat.com> wrote:

> The idea in 9ff473b 'vmscan: evict streaming IO first' was to steer
> reclaim focus onto file pages with every new file page that hits the
> lru list, so that an influx of used-once file pages does not lead to
> swapping of anonymous pages.
> 
> The problem is that nobody is fixing up the balance if the pages in
> fact become part of the resident set.
> 
> Anonymous page creation is neutral to the inter-lru balance, so even a
> comparably tiny number of heavily used file pages tip the balance in
> favor of the file list.
> 
> In addition, there is no refault detection, and every refault will
> bias the balance even more.  A thrashing file working set will be
> mistaken for a very lucrative source of reclaimable pages.
> 
> As anonymous pages are no longer swapped above a certain priority
> level, this mechanism is no longer needed.  Used-once file pages
> should get reclaimed before the VM even considers swapping.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Do you have some results ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
