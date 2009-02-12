Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6213D6B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 19:02:04 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1C020MT030744
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Feb 2009 09:02:01 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A811845DE5B
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 09:02:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C33345DD83
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 09:02:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 34C26E08008
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 09:02:00 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA51B1DB8044
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 09:01:56 +0900 (JST)
Date: Thu, 12 Feb 2009 09:00:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: remove zone->prev_prioriy
Message-Id: <20090212090043.b07d6540.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090211201706.C3C0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090211195252.C3BD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20090211031201.cace1c68.akpm@linux-foundation.org>
	<20090211201706.C3C0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, MinChan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 11 Feb 2009 20:23:39 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Wed, 11 Feb 2009 20:06:46 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > > On Tue, 10 Feb 2009 19:57:01 +0900
> > > > MinChan Kim <minchan.kim@gmail.com> wrote:
> > > > 
> > > > > As you know, prev_priority is used as a measure of how much stress page reclaim.
> > > > > But now we doesn't need it due to split-lru's way.
> > > > > 
> > > > > I think it would be better to remain why prev_priority isn't needed any more
> > > > > and how split-lru can replace prev_priority's role in changelog.
> > > > > 
> > > > > In future, it help mm newbies understand change history, I think.
> > > > 
> > > > Yes, I'd be fascinated to see that explanation.
> > > > 
> > > > In http://groups.google.pn/group/linux.kernel/browse_thread/thread/fea9c9a0b43162a1
> > > > it was asserted that we intend to use prev_priority again in the future.
> > > > 
> > > > We discussed this back in November:
> > > > http://lkml.indiana.edu/hypermail/linux/kernel/0811.2/index.html#00001
> > > > 
> > > > And I think that I still think that the VM got worse due to its (new)
> > > > failure to track previous state.  IIRC, the response to that concern
> > > > was quite similar to handwavy waffling.
> > > 
> > > Yes.
> > > I still think it's valuable code.
> > > I think, In theory, VM sould take parallel reclaim bonus.
> > 
> > prev_priority had nothing to do with concurrent reclaim?
> > 
> > It was there so that when a task enters direct reclaim against a zone,
> > it will immediately adopt the state which the task which most recently
> > ran direct reclaim had.
> > 
> > Without this feature, each time a task enters direct reclaim it will need
> > to "relearn" that state - ramping up, making probably-incorrect
> > decisions as it does so.
> 
> Yes, I perfectly agree to you.
> theorically, prev_priority is very valuable stuff.
> 

Ok, please implement the lost logic again.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
