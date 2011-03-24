Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E27B08D0041
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 01:35:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2E3C43EE0BD
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:09 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EEF1D45DE5A
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D30A345DE5C
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE0331DB804D
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 70B36E08003
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:35:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <20110323200458.724f2af8.akpm@linux-foundation.org>
References: <20110324114842.CC70.A69D9226@jp.fujitsu.com> <20110323200458.724f2af8.akpm@linux-foundation.org>
Message-Id: <20110324143541.CC77.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 24 Mar 2011 14:35:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

> On Thu, 24 Mar 2011 11:48:19 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Thu, 24 Mar 2011 11:11:46 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > 
> > > > Subject: [PATCH] vmscan: remove all_unreclaimable check from direct reclaim path completely
> > > 
> > > zone.all_unreclaimable is there to prevent reclaim from wasting CPU
> > > cycles scanning a zone which has no reclaimable pages.  When originally
> > > implemented it did this very well.
> > >
> > > That you guys keep breaking it, or don't feel like improving it is not a
> > > reason to remove it!
> > > 
> > > If the code is unneeded and the kernel now reliably solves this problem
> > > by other means then this should have been fully explained in the
> > > changelog, but it was not even mentioned.
> > 
> > The changelog says, the logic was removed at 2008. three years ago.
> > even though it's unintentionally. and I and minchan tried to resurrect
> > the broken logic and resurrected a bug in the logic too. then, we
> > are discussed it should die or alive.
> > 
> > Which part is hard to understand for you?
> 
> The part which isn't there: how does the kernel now address the problem
> which that code fixed?

Ah, got it.
The history says the problem haven't occur for three years. thus I
meant

past: code exist, but broken and don't work for three years.
new:  code removed.

What's different? But last minchan's mail pointed out recent
drain_all_pages() stuff depend on a return value of try_to_free_pages.

thus, I've made new patch and sent it. please see it?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
