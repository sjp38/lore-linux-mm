Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9L6QQFD025600
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Oct 2008 15:26:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9300224004A
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:26:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 63E6E2DC12E
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:26:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 50CE51DB803C
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:26:26 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 08BDC1DB8038
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 15:26:23 +0900 (JST)
Date: Tue, 21 Oct 2008 15:25:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] unable to handle kernel NULL pointer derefence at
 00000000
Message-Id: <20081021152557.1540b22e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48FD74AB.9010307@cn.fujitsu.com>
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	<20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	<6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	<20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD6901.6050301@linux.vnet.ibm.com>
	<20081021143955.eeb86d49.kamezawa.hiroyu@jp.fujitsu.com>
	<48FD74AB.9010307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008 14:20:27 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > BTW, "allocate all page_cgroup at boot" patch goes to Linus' git. Wow.
> > 
> 
> But seems this patch causes kernel panic at system boot ... (or maybe one of other
> memcg patches?)
> 
> I wrote down the panic manually:
> 
> BUG: unable to handle kernel NULL pointer dereference at 00000000
> IP: page_cgroup_zoneinfo + 0xa
> 
> Call Trace:
> ? mem_cgroup_charge_common + 0x17d
> ? mem_cgroup_charge
> ? add_to_page_cache_locked
> ? add_to_page_cache_lru
> ? find_or_create_page
> ? __getblk
> ? ext3_get_inode_loc
> ? ext3_iget
> ? ext3_lookup
> 
> Tell me if you need extra information.
> 
This shows how small testers in -mm ...this is on x86 ?
Could you show me your config ? 
and what happens if cgroup_disable=memory ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
