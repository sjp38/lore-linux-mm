Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB8AC8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 03:11:43 -0500 (EST)
Date: Fri, 4 Mar 2011 09:11:32 +0100
From: Daniel Poelzleithner <poelzi@poelzi.org>
Message-ID: <20110304091132.6de2ed94@sol>
In-Reply-To: <20110304165455.d438342a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110304083944.22fb612f@sol>
	<20110304165455.d438342a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Subject: Re: cgroup memory, blkio and the lovely swapping
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Fri, 4 Mar 2011 16:54:55 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Now, blkio cgroup does work only with synchronous I/O(direct I/O)
> and never work with swap I/O. And I don't think swap-i/o limit
> is a blkio matter.

I'm totally unsure about what subsystem it really belongs to. It is
memory for sure, but disk access, which it actually affects, belongs to
the blkio subsystem. Is there a technical reason why swap I/O is not run
through the blkio system ?


> Memory cgroup is now developping dirty_ratio for memory cgroup.
> By that, you can control the number of pages in writeback, in memory
> cgroup. I think it will work for you.

I'm not sure that fixes the fairness problem on swapio. Just having a
larger buffer before a writeback happens will reduce seeks, but not
give fair share of io in swap in. It's good to control over it on
cgroup level, but i doubt it will fix the problem.



kind regards
 Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
