Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F36FA6B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 02:30:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H6Ufc8015134
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 15:30:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DB1945DE4D
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:30:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 65BCF45DD71
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:30:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 445BA1DB803A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:30:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 66CD2E18009
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:30:40 +0900 (JST)
Date: Thu, 17 Sep 2009 15:28:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/8] memcg: migrate charge of swap
Message-Id: <20090917152837.3570cc13.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090917151738.503de68c.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917112817.b3829458.nishimura@mxp.nes.nec.co.jp>
	<20090917142558.58f3e8ef.kamezawa.hiroyu@jp.fujitsu.com>
	<20090917151738.503de68c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 15:17:38 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > BTW, it's not very bad to do this exchange under swap_lock. (if charge is done.)
> > Then, the whole logic can be simple.
> > 
> Current memcg in mmotm calls swap_cgroup_record() under swap_lock except
> __mem_cgroup_commit_charge_swapin().
> Instead of doing all of it under swap_lock, I choose lockless(cmpxchg) implementation.
> 
> 
Ah, sorry for my short word.

   IIUC, we guarantee atomic swap charge/uncharge operation by
   lock_page() .....if there are swap cache
   swap_lock() .....if there are no swap cache.

Then, using swap_lock here can be a choice.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
