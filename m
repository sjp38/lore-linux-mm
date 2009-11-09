Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD016B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 00:08:13 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id nA957unV009442
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 16:07:56 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nA9553du790638
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 16:05:03 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nA9588Bd013334
	for <linux-mm@kvack.org>; Mon, 9 Nov 2009 16:08:08 +1100
Date: Mon, 9 Nov 2009 10:38:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 0/8] memcg: recharge at task move
Message-ID: <20091109050806.GB3042@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-06 14:10:11]:

> Hi.
> 
> In current memcg, charges associated with a task aren't moved to the new cgroup
> at task move. These patches are for this feature, that is, for recharging to
> the new cgroup and, of course, uncharging from old cgroup at task move.
> 
> Current virsion supports only recharge of non-shared(mapcount == 1) anonymous pages
> and swaps of those pages. I think it's enough as a first step.
>

What is the motivation? Is to provide better accountability? I think
it is worthwhile to look into it, provided the cost of migration is
not too high. It was on my list of things to look at, but I found that
if cpu/memory are mounted together and the cost of migration is high,
it can be a bottleneck in some cases. I'll review the patches a bit
more.
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
