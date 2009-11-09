Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E5FCC6B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 00:19:11 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA95J83O022858
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 9 Nov 2009 14:19:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95C9545DE54
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 14:19:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D48E45DE4D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 14:19:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 348B11DB804D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 14:19:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CEDA81DB8041
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 14:19:07 +0900 (JST)
Date: Mon, 9 Nov 2009 14:16:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/8] memcg: recharge at task move
Message-Id: <20091109141609.331eee77.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091109104446.b2d9ef66.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106154542.5ca9bb61.kamezawa.hiroyu@jp.fujitsu.com>
	<20091109104446.b2d9ef66.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Nov 2009 10:44:46 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote: 
> > Seems much nicer but I have some nitpicks as already commented.
> > 
> > For [8/8], mm->swap_usage counter may be a help for making it faster.
> > Concern is how it's shared but will not be very big error.
> > 
> will change as I mentioned in another mail.
> 
> I'll repost 3 and 4 as cleanup(I think they are ready for inclusion),
> and post removal-of-memcg_tasklist as a separate patch.
> 
> I'll postpone the body of this feature(waiting for your percpu change
> and per-process swap counter at least).
> 
Thanks. I agree 1-4 are ready for merge. But, please get ack by Paul.
or Li zefan. Paul, Li, how do you think about [1/8] ?


> > > TODO:
> > > - add support for file cache, shmem/tmpfs, and shared(mapcount > 1) pages.
> > > - implement madvise(2) to let users decide the target vma for recharge.
> > > 
> > 
> > About this, I think "force_move_shared_account" flag is enough, I think.
> > But we have to clarify "mmap()ed but not on page table" entries are not
> > moved....
> > 
> You mean swap entries of shmem/tmpfs, do you ? I agree they are hard to handle..
> 
Yes and No. Including mmaped file.

> 
> My concern is:
> 
> - I want to add support for private file caches, shmes/tmpfs pages(including swaps of them),
>   and "shared" pages by some means in future, and let an admin or a middle-ware
>   decide how to handle them.
Yes, I agree that middle ware may want that.

> - Once this feature has been merged(at .33?), I don't want to change the behavior
>   when a user set "recharge_at_immigrate=1".
>   So, I'll "extend" the meaning of "recharge_at_immigrate" or add a new flag file
>   to support other type of charges.

Yes, I think making recharge_at_immigrate as "bitmask" makes sense.
So, showing "recharge_at_immigrate" is a bitmask _now_ both in code and documentation
in clear way will be a help for future.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
