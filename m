Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E17BF6B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 06:12:10 -0500 (EST)
Date: Wed, 11 Feb 2009 03:12:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: remove zone->prev_prioriy
Message-Id: <20090211031201.cace1c68.akpm@linux-foundation.org>
In-Reply-To: <20090211195252.C3BD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <28c262360902100257o6a8e2374v42f1ae906c53bcec@mail.gmail.com>
	<20090210151247.6747f66e.akpm@linux-foundation.org>
	<20090211195252.C3BD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 11 Feb 2009 20:06:46 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Tue, 10 Feb 2009 19:57:01 +0900
> > MinChan Kim <minchan.kim@gmail.com> wrote:
> > 
> > > As you know, prev_priority is used as a measure of how much stress page reclaim.
> > > But now we doesn't need it due to split-lru's way.
> > > 
> > > I think it would be better to remain why prev_priority isn't needed any more
> > > and how split-lru can replace prev_priority's role in changelog.
> > > 
> > > In future, it help mm newbies understand change history, I think.
> > 
> > Yes, I'd be fascinated to see that explanation.
> > 
> > In http://groups.google.pn/group/linux.kernel/browse_thread/thread/fea9c9a0b43162a1
> > it was asserted that we intend to use prev_priority again in the future.
> > 
> > We discussed this back in November:
> > http://lkml.indiana.edu/hypermail/linux/kernel/0811.2/index.html#00001
> > 
> > And I think that I still think that the VM got worse due to its (new)
> > failure to track previous state.  IIRC, the response to that concern
> > was quite similar to handwavy waffling.
> 
> Yes.
> I still think it's valuable code.
> I think, In theory, VM sould take parallel reclaim bonus.

prev_priority had nothing to do with concurrent reclaim?

It was there so that when a task enters direct reclaim against a zone,
it will immediately adopt the state which the task which most recently
ran direct reclaim had.

Without this feature, each time a task enters direct reclaim it will need
to "relearn" that state - ramping up, making probably-incorrect
decisions as it does so.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
