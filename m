Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 68A426B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 06:23:43 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BBNeqC011034
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 20:23:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 659BD45DE54
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:23:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 419EF45DE4F
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:23:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 156ED1DB803F
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:23:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF5A41DB803A
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:23:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove zone->prev_prioriy
In-Reply-To: <20090211031201.cace1c68.akpm@linux-foundation.org>
References: <20090211195252.C3BD.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090211031201.cace1c68.akpm@linux-foundation.org>
Message-Id: <20090211201706.C3C0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 20:23:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, MinChan Kim <minchan.kim@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> On Wed, 11 Feb 2009 20:06:46 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Tue, 10 Feb 2009 19:57:01 +0900
> > > MinChan Kim <minchan.kim@gmail.com> wrote:
> > > 
> > > > As you know, prev_priority is used as a measure of how much stress page reclaim.
> > > > But now we doesn't need it due to split-lru's way.
> > > > 
> > > > I think it would be better to remain why prev_priority isn't needed any more
> > > > and how split-lru can replace prev_priority's role in changelog.
> > > > 
> > > > In future, it help mm newbies understand change history, I think.
> > > 
> > > Yes, I'd be fascinated to see that explanation.
> > > 
> > > In http://groups.google.pn/group/linux.kernel/browse_thread/thread/fea9c9a0b43162a1
> > > it was asserted that we intend to use prev_priority again in the future.
> > > 
> > > We discussed this back in November:
> > > http://lkml.indiana.edu/hypermail/linux/kernel/0811.2/index.html#00001
> > > 
> > > And I think that I still think that the VM got worse due to its (new)
> > > failure to track previous state.  IIRC, the response to that concern
> > > was quite similar to handwavy waffling.
> > 
> > Yes.
> > I still think it's valuable code.
> > I think, In theory, VM sould take parallel reclaim bonus.
> 
> prev_priority had nothing to do with concurrent reclaim?
> 
> It was there so that when a task enters direct reclaim against a zone,
> it will immediately adopt the state which the task which most recently
> ran direct reclaim had.
> 
> Without this feature, each time a task enters direct reclaim it will need
> to "relearn" that state - ramping up, making probably-incorrect
> decisions as it does so.

Yes, I perfectly agree to you.
theorically, prev_priority is very valuable stuff.

rest only problem is, I should found good workload and re-integrate
prev_priority to reclaim code.

I (and many VM people) strongly dislike any regression.
then, if I can't find good workload, I can't change any VM behavior.

Do you have any suggestion?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
