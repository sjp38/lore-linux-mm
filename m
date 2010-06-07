Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6744C6B01AC
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 02:54:50 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o576fg03028773
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 02:41:42 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o576sl4s137072
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 02:54:47 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o576slmj027350
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 03:54:47 -0300
Date: Mon, 7 Jun 2010 12:24:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [cleanup][PATCH -mmotm 1/2] memcg: remove redundant codes
Message-ID: <20100607065431.GQ4603@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100607145239.cb5cb917.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100607145239.cb5cb917.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2010-06-07 14:52:39]:

> These patches are based on mmotm-2010-06-03-16-36 + some already merged patches
> for memcg.
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> - try_get_mem_cgroup_from_mm() calls rcu_read_lock/unlock by itself, so we
>   don't have to call them in task_in_mem_cgroup().
> - *mz is not used in __mem_cgroup_uncharge_common().
> - we don't have to call lookup_page_cgroup() in mem_cgroup_end_migration()
>   after we've cleared PCG_MIGRATION of @oldpage.
> - remove empty comment.
> - remove redundant empty line in mem_cgroup_cache_charge().
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
