Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C238B6B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 06:06:49 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BB6lUo008660
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 20:06:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7594945DE55
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:06:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5630C45DD79
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:06:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AC741DB803A
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:06:47 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E0752E18001
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:06:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove zone->prev_prioriy
In-Reply-To: <20090210151247.6747f66e.akpm@linux-foundation.org>
References: <28c262360902100257o6a8e2374v42f1ae906c53bcec@mail.gmail.com> <20090210151247.6747f66e.akpm@linux-foundation.org>
Message-Id: <20090211195252.C3BD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 20:06:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, MinChan Kim <minchan.kim@gmail.com>, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> On Tue, 10 Feb 2009 19:57:01 +0900
> MinChan Kim <minchan.kim@gmail.com> wrote:
> 
> > As you know, prev_priority is used as a measure of how much stress page reclaim.
> > But now we doesn't need it due to split-lru's way.
> > 
> > I think it would be better to remain why prev_priority isn't needed any more
> > and how split-lru can replace prev_priority's role in changelog.
> > 
> > In future, it help mm newbies understand change history, I think.
> 
> Yes, I'd be fascinated to see that explanation.
> 
> In http://groups.google.pn/group/linux.kernel/browse_thread/thread/fea9c9a0b43162a1
> it was asserted that we intend to use prev_priority again in the future.
> 
> We discussed this back in November:
> http://lkml.indiana.edu/hypermail/linux/kernel/0811.2/index.html#00001
> 
> And I think that I still think that the VM got worse due to its (new)
> failure to track previous state.  IIRC, the response to that concern
> was quite similar to handwavy waffling.

Yes.
I still think it's valuable code.
I think, In theory, VM sould take parallel reclaim bonus.

However, recently, KAMEZAWA-san reported memcg prev_priority code are
busted due to hierarchical-memory-reclaim and he dislike maintain 
unused function.

http://marc.info/?l=linux-mm&m=123258289017433&w=2


and, at that time I can't show good example workload of parallel reclaim bonus
effective.
Therefore I agreed to drop this and insert it again at re-using time ;-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
