Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 28C958D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 23:09:21 -0400 (EDT)
Date: Wed, 23 Mar 2011 20:04:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
Message-Id: <20110323200458.724f2af8.akpm@linux-foundation.org>
In-Reply-To: <20110324114842.CC70.A69D9226@jp.fujitsu.com>
References: <20110324111200.1AF4.A69D9226@jp.fujitsu.com>
	<20110323192150.9895afe3.akpm@linux-foundation.org>
	<20110324114842.CC70.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, 24 Mar 2011 11:48:19 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Thu, 24 Mar 2011 11:11:46 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > Subject: [PATCH] vmscan: remove all_unreclaimable check from direct reclaim path completely
> > 
> > zone.all_unreclaimable is there to prevent reclaim from wasting CPU
> > cycles scanning a zone which has no reclaimable pages.  When originally
> > implemented it did this very well.
> >
> > That you guys keep breaking it, or don't feel like improving it is not a
> > reason to remove it!
> > 
> > If the code is unneeded and the kernel now reliably solves this problem
> > by other means then this should have been fully explained in the
> > changelog, but it was not even mentioned.
> 
> The changelog says, the logic was removed at 2008. three years ago.
> even though it's unintentionally. and I and minchan tried to resurrect
> the broken logic and resurrected a bug in the logic too. then, we
> are discussed it should die or alive.
> 
> Which part is hard to understand for you?
> 

The part which isn't there: how does the kernel now address the problem
which that code fixed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
