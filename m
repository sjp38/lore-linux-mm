Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 201DF6B004F
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:21:03 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4U599RR021574
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:09:09 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4U5LIIj234880
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:21:18 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4U5JAEA004343
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:19:11 -0400
Date: Sat, 30 May 2009 13:21:13 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] add swap cache interface for swap reference v2
	(updated)
Message-ID: <20090530052113.GD24073@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com> <20090528141049.cc45a116.kamezawa.hiroyu@jp.fujitsu.com> <20090529132153.3a72f2c3.nishimura@mxp.nes.nec.co.jp> <20090529140832.1f4b288b.kamezawa.hiroyu@jp.fujitsu.com> <20090529143758.4c3db3eb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090529143758.4c3db3eb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-29 14:37:58]:

> On Fri, 29 May 2009 14:08:32 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > IIUC, swap_free() at the end of shmem_writepage() should also be changed to swapcache_free().
> > > 
> > Hmm!. Oh, yes. shmem_writepage()'s error path. Thank you. It will be fixed.
> > 
> here. 
> 
> ==
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In following patch, usage of swap cache will be recorded into swap_map.
> This patch is for necessary interface changes to do that.
> 
> 2 interfaces:
>   - swapcache_prepare()
>   - swapcache_free()
> is added for allocating/freeing refcnt from swap-cache to existing
> swap entries. But implementation itself is not changed under this patch.
> At adding swapcache_free(), memcg's hook code is moved under swapcache_free().
> This is better than using scattered hooks.
> 
> Changelog: v1->v2
>  - fixed shmem_writepage() error path.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Looks good to me so far

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
