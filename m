Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E0D0C6B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 22:50:22 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n612puDW005107
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Jul 2009 11:51:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4851E45DE58
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:51:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 179B945DE53
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:51:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DD3211DB803F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:51:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 92DD4E08001
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:51:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Found the commit that causes the OOMs
In-Reply-To: <20090701022644.GA7510@localhost>
References: <20090701021645.GA6356@localhost> <20090701022644.GA7510@localhost>
Message-Id: <20090701114959.85D3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Jul 2009 11:51:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> > > What is "hidden" anon pages?
> > > each shrink_{in}active_list isolate 32 pages from lru. it mean anon or file lru
> > > accounting decrease temporary.
> > > 
> > > if system have plenty thread or process, heavy memory pressure makes 
> > > #-of-thread x 32pages isolation.
> > > 
> > > msgctl11 makes >10K processes.
> > 
> > More exactly, ~16K processes:
> > 
> >         msgctl11    0  INFO  :  Using upto 16298 pids
> > 
> > So the maximum number of isolated pages is 16K * 32 = 512K, or 2GiB.
> > 
> > > I have debugging patch for this case.
> > > Wu, Can you please try this patch?
> > 
> > OK. But the OOM is not quite reproducible. Sometimes it produces these
> > messages:
> 
> This time I got the OOM: there are 69817 isolated pages (just as expected)!
> 
(snip)

> [ 1522.019259] Active_anon:11 active_file:6 inactive_anon:0
> [ 1522.019260]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
> [ 1522.019261]  free:1985 slab:44399 mapped:132 pagetables:61830 bounce:0
> [ 1522.019262]  isolate:69817

OK. thanks.
I plan to submit this patch after small more tests. it is useful for OOM analysis.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
