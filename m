Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3DEF56B00BA
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 21:53:14 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA92rBbd009690
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 11:53:11 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0372A45DE56
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:53:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4C7445DE50
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:53:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA4801DB8045
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:53:10 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 658641DB8051
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:53:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for protecting the working set
In-Reply-To: <20101104015249.GD19646@google.com>
References: <AANLkTimCjUgy9sN5QzxwW960v9eNWAjMBdq3H6P20NUa@mail.gmail.com> <20101104015249.GD19646@google.com>
Message-Id: <20101109115118.BC3C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 11:53:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

> > I don't think current VM behavior has a problem.
> > Current problem is that you use up many memory than real memory.
> > As system memory without swap is low, VM doesn't have a many choice.
> > It ends up evict your working set to meet for user request. It's very
> > natural result for greedy user.
> > 
> > Rather than OOM notifier, what we need is memory notifier.
> > AFAIR, before some years ago, KOSAKI tried similar thing .
> > http://lwn.net/Articles/268732/
> 
> Thanks! This is perfect. I wonder why its not merged. Was a different
> solution eventually implemented? Is there another way of doing the
> same thing?

Now memcg has memory threshold notification feature and almost people
are using it. If you think notification fit your case, can you please
try this feature at first?
And if it doesn't fit your case and we will get a feedback from you, 
we probably can extend such one.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
