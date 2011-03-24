Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1718D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 22:48:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 491833EE0C0
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:48:21 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F6B645DE56
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:48:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 01AC145DE59
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:48:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E6B05E08005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:48:20 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B09191DB8046
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:48:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <20110323192150.9895afe3.akpm@linux-foundation.org>
References: <20110324111200.1AF4.A69D9226@jp.fujitsu.com> <20110323192150.9895afe3.akpm@linux-foundation.org>
Message-Id: <20110324114842.CC70.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 24 Mar 2011 11:48:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

> On Thu, 24 Mar 2011 11:11:46 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > Subject: [PATCH] vmscan: remove all_unreclaimable check from direct reclaim path completely
> 
> zone.all_unreclaimable is there to prevent reclaim from wasting CPU
> cycles scanning a zone which has no reclaimable pages.  When originally
> implemented it did this very well.
>
> That you guys keep breaking it, or don't feel like improving it is not a
> reason to remove it!
> 
> If the code is unneeded and the kernel now reliably solves this problem
> by other means then this should have been fully explained in the
> changelog, but it was not even mentioned.

The changelog says, the logic was removed at 2008. three years ago.
even though it's unintentionally. and I and minchan tried to resurrect
the broken logic and resurrected a bug in the logic too. then, we
are discussed it should die or alive.

Which part is hard to understand for you?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
