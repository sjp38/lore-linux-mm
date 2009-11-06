Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9B35E6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 01:09:15 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA669CXS007312
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 15:09:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 94D7645DE4F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:09:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 753F045DE4E
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:09:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 605F41DB8040
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:09:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FAB91DB803F
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:09:12 +0900 (JST)
Date: Fri, 6 Nov 2009 15:06:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 5/8] memcg: add interface to recharge at task
 move
Message-Id: <20091106150640.52c92ce8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091106141418.07338b99.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106141418.07338b99.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 14:14:18 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> In current memcg, charges associated with a task aren't moved to the new cgroup
> at task move. These patches are for this feature, that is, for recharging to
> the new cgroup and, of course, uncharging from old cgroup at task move.
> 
> This patch adds "memory.recharge_at_immigrate" file, which is a flag file to
> determine whether charges should be moved to the new cgroup at task move or
> not, and read/write handlers of the file.
> This patch also adds no-op handlers for this feature. These handlers will be
> implemented in later patches.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, Even if this patch is just for interface, adding Documentation here
is a good choice, I think. It makes things clear.

> +
> +	if (mem->recharge_at_immigrate && thread_group_leader(p))
> +		ret = mem_cgroup_can_recharge(mem, p);

My small concern is whtehter thread_group_leader(p) is _always_ equal to
mm->owner..If not, things will be complicated.

Could you clarify ? If mm->owner is better, we should use mm->owner here.
(Non-usual case but..)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
