Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B277A6B0082
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 03:01:30 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3R71TNM016923
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 27 Apr 2009 16:01:29 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4269B45DE57
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:01:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 22A0145DE52
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:01:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E45E1DB8038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:01:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B3ECD1DB8043
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 16:01:25 +0900 (JST)
Date: Mon, 27 Apr 2009 15:59:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix try_get_mem_cgroup_from_swapcache()
Message-Id: <20090427155953.32990d5a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090427065358.GB4454@balbir.in.ibm.com>
References: <20090426231752.36498c90.d-nishimura@mtf.biglobe.ne.jp>
	<20090427095100.29173bc1.nishimura@mxp.nes.nec.co.jp>
	<20090427065358.GB4454@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 12:23:58 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-04-27 09:51:00]:
> 
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > memcg: fix try_get_mem_cgroup_from_swapcache()
> > 
> > This is a bugfix for commit 3c776e64660028236313f0e54f3a9945764422df(included 2.6.30-rc1).
> > Used bit of swapcache is solid under page lock, but considering move_account,
> > pc->mem_cgroup is not.
> > 
> > We need lock_page_cgroup() anyway.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> I think we need to start documenting the locks the
> page_cgroup lock nests under.
> 
Addin some comments on source code may be necessary.

> If memcg_tasklist were a spinlock instead of mutex, could we use that
> instead of page_cgroup lock, since we care only about task migration?
> 

Hmm ? Another problem ? I can't catch what you ask.
move_account() is a function called by force_empty()->"move account to parent"

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
