Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1ACDD6B006A
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 21:49:55 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F2nqng009318
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 11:49:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ADA445DD72
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:49:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5930D45DE53
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:49:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E1451DB803F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:49:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 64C241DB803B
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:49:51 +0900 (JST)
Date: Thu, 15 Jan 2009 11:48:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090115114846.388781a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090114135539.GA21516@balbir.in.ibm.com>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<20090114135539.GA21516@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jan 2009 19:25:39 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-14 17:51:21]:
> 
> > This is a new one. Please review.
> > 
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > mem_cgroup_get ensures that the memcg that has been got can be accessed
> > even after the directory has been removed, but it doesn't ensure that parents
> > of it can be accessed: parents might have been freed already by rmdir.
> > 
> > This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> > climb up the tree.
> > 
> > Check if the memcg is obsolete, and don't call res_counter_uncharge when obsole.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> I liked the earlier, EBUSY approach that ensured that parents could
> not go away if children exist. IMHO, the code has gotten too complex
> and has too many corner cases. Time to revisit it.
> 
It's on my plan. 
I'll fix this by CSS-ID patch.

When I recored memcg's CSS-ID to swap_cgroup (not pointer to memcg), 
we never need memcg's refcnt.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
