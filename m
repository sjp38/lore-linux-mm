Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE4016B007E
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 02:54:08 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3R6stAu023681
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:24:55 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3R6spnH520394
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:24:55 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3R6spOV017897
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:24:51 +0530
Date: Mon, 27 Apr 2009 12:23:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix try_get_mem_cgroup_from_swapcache()
Message-ID: <20090427065358.GB4454@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090426231752.36498c90.d-nishimura@mtf.biglobe.ne.jp> <20090427095100.29173bc1.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090427095100.29173bc1.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-04-27 09:51:00]:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> memcg: fix try_get_mem_cgroup_from_swapcache()
> 
> This is a bugfix for commit 3c776e64660028236313f0e54f3a9945764422df(included 2.6.30-rc1).
> Used bit of swapcache is solid under page lock, but considering move_account,
> pc->mem_cgroup is not.
> 
> We need lock_page_cgroup() anyway.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

I think we need to start documenting the locks the
page_cgroup lock nests under.

If memcg_tasklist were a spinlock instead of mutex, could we use that
instead of page_cgroup lock, since we care only about task migration?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
