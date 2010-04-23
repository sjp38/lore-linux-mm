Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B7D106B01E3
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 02:08:44 -0400 (EDT)
Message-ID: <4BD139D8.80309@cn.fujitsu.com>
Date: Fri, 23 Apr 2010 14:10:32 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] memcg rcu lock fix v3
References: <4BD10D59.9090504@cn.fujitsu.com>	<20100423121424.ae47efcb.kamezawa.hiroyu@jp.fujitsu.com>	<4BD118E2.7080307@cn.fujitsu.com>	<4BD11A24.2070500@cn.fujitsu.com>	<20100423125814.01e95bce.kamezawa.hiroyu@jp.fujitsu.com> <20100423130349.f320d0be.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100423130349.f320d0be.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> css_id() should be called under rcu_read_lock().
> Following is a report from Li Zefan.
> ==
> ===================================================
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> kernel/cgroup.c:4438 invoked rcu_dereference_check() without protection!
> 
> other info that might help us debug this:
> 
> 
> rcu_scheduler_active = 1, debug_locks = 1
> 1 lock held by kswapd0/31:
>  #0:  (swap_lock){+.+.-.}, at: [<c05058bb>] swap_info_get+0x4b/0xd0
> 
> stack backtrace:
...
> 
> And css_is_ancestor() should be called under rcu_read_lock().
> 
> 
> Reported-by: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

With this patch applied, I did some more test, and no warning was triggered.

Tested-by: Li Zefan <lizf@cn.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
