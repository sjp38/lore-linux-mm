Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AF7EF8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 03:30:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 44E0D3EE0BD
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:30:50 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C07845DE53
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:30:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0086C45DE55
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:30:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E71AA1DB8049
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:30:49 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B1C191DB8046
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:30:49 +0900 (JST)
Date: Fri, 4 Mar 2011 17:24:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: cgroup memory, blkio and the lovely swapping
Message-Id: <20110304172430.19a3824a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110304091132.6de2ed94@sol>
References: <20110304083944.22fb612f@sol>
	<20110304165455.d438342a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110304091132.6de2ed94@sol>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Poelzleithner <poelzi@poelzi.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Fri, 4 Mar 2011 09:11:32 +0100
Daniel Poelzleithner <poelzi@poelzi.org> wrote:

> On Fri, 4 Mar 2011 16:54:55 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Now, blkio cgroup does work only with synchronous I/O(direct I/O)
> > and never work with swap I/O. And I don't think swap-i/o limit
> > is a blkio matter.
> 
> I'm totally unsure about what subsystem it really belongs to. It is
> memory for sure, but disk access, which it actually affects, belongs to
> the blkio subsystem. Is there a technical reason why swap I/O is not run
> through the blkio system ?
> 

Now, blkio cgroup has no tags on each page. Then, it works only when
it can detect a thread which starts I/O in block layer.
But there is an activity to fix that.

http://marc.info/?l=linux-mm&m=129888823027871&w=2

I think you can discuss swap io handling in this thread.

> 
> > Memory cgroup is now developping dirty_ratio for memory cgroup.
> > By that, you can control the number of pages in writeback, in memory
> > cgroup. I think it will work for you.
> 
> I'm not sure that fixes the fairness problem on swapio. Just having a
> larger buffer before a writeback happens will reduce seeks, but not
> give fair share of io in swap in. It's good to control over it on
> cgroup level, but i doubt it will fix the problem.
> 

swap-in is out-of-control from memcg's view and have no plans.
IHMO, the number of swap-in will be blkio cgroup matter.

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
