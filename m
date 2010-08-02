Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C5275600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 16:42:23 -0400 (EDT)
Date: Mon, 2 Aug 2010 13:43:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
Message-Id: <20100802134312.c0f48615.akpm@linux-foundation.org>
In-Reply-To: <20100730195338.4AF6.A69D9226@jp.fujitsu.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com>
	<20100729183809.ca4ed8be.akpm@linux-foundation.org>
	<20100730195338.4AF6.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 Jul 2010 20:02:13 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Fri, 30 Jul 2010 09:12:26 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > > On Sat, 17 Jul 2010 12:16:33 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > > > 
> > > > > This a complete rewrite of the oom killer's badness() heuristic 
> > > > 
> > > > Any comments here, or are we ready to proceed?
> > > > 
> > > > Gimme those acked-bys, reviewed-bys and tested-bys, please!
> > > 
> > > If he continue to resend all of rewrite patch, I continue to refuse them.
> > > I explained it multi times.
> > 
> > There are about 1000 emails on this topic.  Please briefly explain it again.
> 
> Major homework are
> 
> - make patch series instead unreviewable all in one patch.

Sometimes that's not very practical and the splitup isn't necessarily a
lot easier to understand and review.

It's still possible to review the end result - just read the patched code.

> - kill oom_score_adj

Unclear why?

> - write test way and test result

I think David's done quite a bit of that?

> So, I'm pending reviewing until finish them. I'd like to point out 
> rest minor topics while reviewing process.

I think I'll merge it into 2.6.36.  That gives us two months to
continue to review it, to test it and if necessary, to fix it or revert
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
