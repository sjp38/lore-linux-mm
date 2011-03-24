Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC578D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 22:25:42 -0400 (EDT)
Date: Wed, 23 Mar 2011 19:21:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct
 reclaim path completely
Message-Id: <20110323192150.9895afe3.akpm@linux-foundation.org>
In-Reply-To: <20110324111200.1AF4.A69D9226@jp.fujitsu.com>
References: <20110323174545.1AE2.A69D9226@jp.fujitsu.com>
	<AANLkTi=w62=WR5WACJGk6JNhyCYpgNhFQK3CyQ5Ag-Yj@mail.gmail.com>
	<20110324111200.1AF4.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, 24 Mar 2011 11:11:46 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Subject: [PATCH] vmscan: remove all_unreclaimable check from direct reclaim path completely

zone.all_unreclaimable is there to prevent reclaim from wasting CPU
cycles scanning a zone which has no reclaimable pages.  When originally
implemented it did this very well.

That you guys keep breaking it, or don't feel like improving it is not a
reason to remove it!

If the code is unneeded and the kernel now reliably solves this problem
by other means then this should have been fully explained in the
changelog, but it was not even mentioned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
