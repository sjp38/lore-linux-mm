Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 849B46B01EE
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 02:09:25 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N69QRm026535
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 15:09:27 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A7F9245DE66
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 15:09:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C63545DE5D
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 15:09:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 59E281DB8048
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 15:09:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C98A61DB8041
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 15:09:25 +0900 (JST)
Date: Fri, 23 Apr 2010 15:05:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix v3
Message-Id: <20100423150530.469566ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BD139D8.80309@cn.fujitsu.com>
References: <4BD10D59.9090504@cn.fujitsu.com>
	<20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>
	<4BD118E2.7080307@cn.fujitsu.com>
	<4BD11A24.2070500@cn.fujitsu.com>
	<20100423125814.01e95bce.kamezawa.hiroyu@jp.fujitsu.com>
	<20100423130349.f320d0be.kamezawa.hiroyu@jp.fujitsu.com>
	<4BD139D8.80309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 14:10:32 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > css_id() should be called under rcu_read_lock().
> > Following is a report from Li Zefan.
> > ==
> > ===================================================
> > [ INFO: suspicious rcu_dereference_check() usage. ]
> > ---------------------------------------------------
> > kernel/cgroup.c:4438 invoked rcu_dereference_check() without protection!
> > 
> > other info that might help us debug this:
> > 
> > 
> > rcu_scheduler_active = 1, debug_locks = 1
> > 1 lock held by kswapd0/31:
> >  #0:  (swap_lock){+.+.-.}, at: [<c05058bb>] swap_info_get+0x4b/0xd0
> > 
> > stack backtrace:
> ...
> > 
> > And css_is_ancestor() should be called under rcu_read_lock().
> > 
> > 
> > Reported-by: Li Zefan <lizf@cn.fujitsu.com>
> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> With this patch applied, I did some more test, and no warning was triggered.
> 
> Tested-by: Li Zefan <lizf@cn.fujitsu.com>
> 
Thank you!.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
