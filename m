Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 476786B0078
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 10:32:37 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id o14FWVT3027567
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 21:02:31 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o14FWV5s2609272
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 21:02:31 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o14FWUJL008668
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 02:32:30 +1100
Date: Thu, 4 Feb 2010 21:02:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-ID: <20100204153228.GL19641@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
 <20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp>
 <20100203193127.fe5efa17.akpm@linux-foundation.org>
 <20100204140942.0ef6d7b1.nishimura@mxp.nes.nec.co.jp>
 <20100204142736.2a8bec26.kamezawa.hiroyu@jp.fujitsu.com>
 <20100204071840.GC5574@linux-sh.org>
 <20100204164441.d012f6fa.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100204164441.d012f6fa.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-02-04 16:44:41]:

> On Thu, 4 Feb 2010 16:18:40 +0900
> Paul Mundt <lethal@linux-sh.org> wrote:
> 
> > On Thu, Feb 04, 2010 at 02:27:36PM +0900, KAMEZAWA Hiroyuki wrote:
> 
> > > I think memcg should depends on CONIFG_MMU.
> > > 
> > > How do you think ?
> > > 
> > Unless there's a real technical reason to make it depend on CONFIG_MMU,
> > that's just papering over the problem, and means that some nommu person
> > will have to come back and fix it properly at a later point in time.
> > 
> I have no strong opinion this. It's ok to support as much as possible.
> My concern is that there is no !MMU architecture developper around memcg. So,
> error report will be delayed.
>

I don't mind making it depend on CONFIG_MMU, enabling it for
!CONFIG_MMU will require some careful thought and work, so I'd rather
make that obvious by making it depend on CONFIG_MMU
 
> 
> > CONFIG_SWAP itself is configurable even with CONFIG_MMU=y, so having
> > stubbed out helpers for the CONFIG_SWAP=n case would give the compiler a
> > chance to optimize things away in those cases, too. Embedded systems
> > especially will often have MMU=y and BLOCK=n, resulting in SWAP being
> > unset but swap cache encodings still defined.
> > 
> > How about just changing the is_swap_pte() definition to depend on SWAP
> > instead?
> > 
> I think the new feature as "move task charge" itself depends on CONFIG_MMU
> because it walks a process's page table. 
> 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
