Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22DA48D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 03:01:19 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 334413EE0BC
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:01:15 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1768C45DE59
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:01:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F3B5545DE56
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:01:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7F47E08005
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:01:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B15C3E08001
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 17:01:14 +0900 (JST)
Date: Fri, 4 Mar 2011 16:54:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: cgroup memory, blkio and the lovely swapping
Message-Id: <20110304165455.d438342a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110304083944.22fb612f@sol>
References: <20110304083944.22fb612f@sol>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Daniel Poelzleithner <poelzi@poelzi.org>, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Fri, 4 Mar 2011 08:39:44 +0100
Daniel Poelzleithner <poelzi@poelzi.org> wrote:

> Hi,
> 
> currently when one process causes heavy swapping, the responsiveness of
> the hole system suffers greatly. With the small memleak [1] test tool I
> wrote, the effect can be experienced very easily, depending on the
> delay the lag can become quite large. If I ensure that 10% of the RAM
> stay free for free memory and cache, the system never swaps to death.
> That works very well, but if accesses to the swap are very heavy, the
> system still lags on all other processes, not only the swapping one.
> Putting the swapping process into a blkio cgroup with little weight does
> not affect the io or swap io from other processes with larger weight in
> their group.
> 
> Maybe I'm mistaken, but wouldn't it be the easiest way to get fair
> swapping and control to let the pagein respect the blkio.weight value
> or even better add a second weight value for swapping io ?
> 

Now, blkio cgroup does work only with synchronous I/O(direct I/O)
and never work with swap I/O. And I don't think swap-i/o limit
is a blkio matter.

Memory cgroup is now developping dirty_ratio for memory cgroup.
By that, you can control the number of pages in writeback, in memory cgroup.
I think it will work for you.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
