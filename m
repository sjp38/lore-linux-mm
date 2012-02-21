Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 1D0156B00EA
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 17:13:23 -0500 (EST)
Received: by dadv6 with SMTP id v6so9011521dad.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 14:13:22 -0800 (PST)
Date: Tue, 21 Feb 2012 14:12:58 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 9/10] mm/memcg: move lru_lock into lruvec
In-Reply-To: <4F440E1D.7050004@openvz.org>
Message-ID: <alpine.LSU.2.00.1202211406030.2012@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201537040.23274@eggly.anvils> <4F434300.3080001@openvz.org> <alpine.LSU.2.00.1202211205280.1858@eggly.anvils> <4F440E1D.7050004@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 22 Feb 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > 
> > I'll have to come back to think about your locking later too;
> > or maybe that's exactly where I need to look, when investigating
> > the mm_inline.h:41 BUG.
> 
> pages_count[] updates looks correct.
> This really may be bug in locking, and this VM_BUG_ON catch it before
> list-debug.

I've still not got into looking at it yet.

You're right to mention DEBUG_LIST: I have that on some of the machines,
and I would expect that to be the first to catch a mislocking issue.

In the past my problems with that BUG (well, the spur to introduce it)
came from hugepages.

> > 
> > But at first sight, I have to say I'm very suspicious: I've never found
> > PageLRU a good enough test for whether we need such a lock, because of
> > races with those pages on percpu lruvec about to be put on the lru.
> > 
> > But maybe once I look closer, I'll find that's handled by your changes
> > away from lruvec; though I'd have thought the same issue exists,
> > independent of whether the pending pages are in vector or list.
> 
> Are you talking about my per-cpu page-lists for lru-adding?

Yes.

> This is just an unnecessary patch, I don't know why I include it into v2 set.
> It does not protect anything.

Okay.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
