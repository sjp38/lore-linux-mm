Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7E63C6B005D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 22:04:18 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2I24Fae032652
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 18 Mar 2009 11:04:15 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4464645DE53
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 11:04:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2993045DE50
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 11:04:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F2C91DB8038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 11:04:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CDC261DB803A
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 11:04:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <200903170323.45917.nickpiggin@yahoo.com.au>
References: <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <200903170323.45917.nickpiggin@yahoo.com.au>
Message-Id: <20090318105735.BD17.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 18 Mar 2009 11:04:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi


> > ---
> >  fs/direct-io.c            |    2 ++
> >  include/linux/init_task.h |    1 +
> >  include/linux/mm_types.h  |    3 +++
> >  kernel/fork.c             |    3 +++
> >  4 files changed, 9 insertions(+), 0 deletions(-)
> 
> It is an interesting patch. Thanks for throwing it into the discussion.
> I do prefer to close the race up for all cases if we decide to do
> anything at all about it, ie. all or nothing. But maybe others disagree.

Honestly, I wan't excepting linus's reaction. but I hope to make my v2.

My point is:
  - my patch don't prevent implement madvice(DONTCOW), I think.
  - andrea patch's complexity is mainly caused by avoiding perfromance degression effort,
    then, kernel later improvement can shrink his patch automatically.
    furtunately KSM don't merge yet. we can discuss his patch again at KSM submitting.
  - anyway, it can fix the bug.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
