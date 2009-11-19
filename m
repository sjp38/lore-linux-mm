Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 753406B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 14:04:09 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp02.au.ibm.com (8.14.3/8.13.1) with ESMTP id nAJJ1SYU021230
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 06:01:28 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAJJ421u1458286
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 06:04:04 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAJJ41do025216
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 06:04:02 +1100
Date: Fri, 20 Nov 2009 00:33:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: recharge at task move (19/Nov)
Message-ID: <20091119190359.GJ31961@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-19 13:27:34]:

> Hi.
> 
> These are current patches of my recharge-at-task-move feature.
> They(precisely, only [5/5]) are dependent on KAMEZAWA-san's per-process swap usage patch,
> which is not merged yet, so are not for inclusion yet. I post them just for review and
> to share my current code.
> 
> In current memcg, charges associated with a task aren't moved to the new cgroup
> at task move. Some users feel this behavior to be strange.
> These patches are for this feature, that is, for recharging to
> the new cgroup and, of course, uncharging from old cgroup at task move.
> 
> Current version supports only recharge of non-shared(mapcount == 1) anonymous pages
> and swaps of those pages. I think it's enough as a first step.
> 
>   [1/5] cgroup: introduce cancel_attach()
>   [2/5] memcg: add interface to recharge at task move
>   [3/5] memcg: recharge charges of anonymous page
>   [4/5] memcg: avoid oom during recharge at task move
>   [5/5] memcg: recharge charges of anonymous swap
>

Thanks for the posting, I'll test and review the patches (hopefully
tomorrow).
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
