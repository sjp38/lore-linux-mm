Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0B0966B0085
	for <linux-mm@kvack.org>; Tue, 19 May 2009 04:06:34 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4J86coD032735
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 19 May 2009 17:06:38 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F122D45DE6B
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:06:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A8A8945DE61
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:06:37 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 729A5E3800D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:06:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BDFE31DB8044
	for <linux-mm@kvack.org>; Tue, 19 May 2009 17:06:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class citizen
In-Reply-To: <20090519074925.GA690@localhost>
References: <20090519161756.4EE4.A69D9226@jp.fujitsu.com> <20090519074925.GA690@localhost>
Message-Id: <20090519170208.742C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 19 May 2009 17:06:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> > > Like the console mode, the absolute nr_mapped drops considerably - to 1/13 of
> > > the original size - during the streaming IO.
> > > 
> > > The delta of pgmajfault is 3 vs 107 during IO, or 236 vs 393 during the whole
> > > process.
> > 
> > hmmm.
> > 
> > about 100 page fault don't match Elladan's problem, I think.
> > perhaps We missed any addional reproduce condition?
> 
> Elladan's case is not the point of this test.
> Elladan's IO is use-once, so probably not a caching problem at all.
> 
> This test case is specifically devised to confirm whether this patch
> works as expected. Conclusion: it is.

Dejection ;-)

The number should address the patch is useful or not. confirming as expected
is not so great.
I don't think your patch is strange, but I really want to find reproduce way.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
