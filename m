Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D5FD6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 18:13:15 -0500 (EST)
Date: Tue, 10 Feb 2009 15:12:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: remove zone->prev_prioriy
Message-Id: <20090210151247.6747f66e.akpm@linux-foundation.org>
In-Reply-To: <28c262360902100257o6a8e2374v42f1ae906c53bcec@mail.gmail.com>
References: <20090210184055.6FCB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<28c262360902100257o6a8e2374v42f1ae906c53bcec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Feb 2009 19:57:01 +0900
MinChan Kim <minchan.kim@gmail.com> wrote:

> As you know, prev_priority is used as a measure of how much stress page reclaim.
> But now we doesn't need it due to split-lru's way.
> 
> I think it would be better to remain why prev_priority isn't needed any more
> and how split-lru can replace prev_priority's role in changelog.
> 
> In future, it help mm newbies understand change history, I think.

Yes, I'd be fascinated to see that explanation.

In http://groups.google.pn/group/linux.kernel/browse_thread/thread/fea9c9a0b43162a1
it was asserted that we intend to use prev_priority again in the future.

We discussed this back in November:
http://lkml.indiana.edu/hypermail/linux/kernel/0811.2/index.html#00001

And I think that I still think that the VM got worse due to its (new)
failure to track previous state.  IIRC, the response to that concern
was quite similar to handwavy waffling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
