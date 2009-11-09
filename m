Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 716546B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 03:36:35 -0500 (EST)
Date: Mon, 9 Nov 2009 17:24:44 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 0/8] memcg: recharge at task move
Message-Id: <20091109172444.00ceae65.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091109050806.GB3042@balbir.in.ibm.com>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091109050806.GB3042@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Nov 2009 10:38:06 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-06 14:10:11]:
> 
> > Hi.
> > 
> > In current memcg, charges associated with a task aren't moved to the new cgroup
> > at task move. These patches are for this feature, that is, for recharging to
> > the new cgroup and, of course, uncharging from old cgroup at task move.
> > 
> > Current virsion supports only recharge of non-shared(mapcount == 1) anonymous pages
> > and swaps of those pages. I think it's enough as a first step.
> >
> 
> What is the motivation? Is to provide better accountability? I think
> it is worthwhile to look into it, provided the cost of migration is
> not too high. It was on my list of things to look at, but I found that
> if cpu/memory are mounted together and the cost of migration is high,
> it can be a bottleneck in some cases. I'll review the patches a bit
> more.
>  
My purpose of using memcg is to restrict the usage of memory/swap by a group of processes.
IOW, prepare a box with a configurable size and put processes into it.

The point is, there is users who think charges are associated with processes not with the box.
Current behavior is very unnatural for those users.
If a user comes to want to manage some processes under another new box,
because, for example, they use more memory than expected and he wants to isolate
the influence from the original group, current behavior is very bad.

Anyway, we don't move any charge by default and an admin or a middle-ware can
decide the behavior.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
