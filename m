Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8536A6B008A
	for <linux-mm@kvack.org>; Sat, 30 May 2009 02:40:11 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4U6auIF022443
	for <linux-mm@kvack.org>; Sat, 30 May 2009 00:36:56 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4U6elQ1145666
	for <linux-mm@kvack.org>; Sat, 30 May 2009 00:40:47 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4U6elxu028758
	for <linux-mm@kvack.org>; Sat, 30 May 2009 00:40:47 -0600
Date: Sat, 30 May 2009 14:40:41 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4] reuse unused swap entry if necessary
Message-ID: <20090530064041.GF24073@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com> <20090528142047.3069543b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090528142047.3069543b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-28 14:20:47]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, we can know a swap entry is just used as SwapCache via swap_map,
> without looking up swap cache.
> 
> Then, we have a chance to reuse swap-cache-only swap entries in
> get_swap_pages().
> 
> This patch tries to free swap-cache-only swap entries if swap is
> not enough.
> Note: We hit following path when swap_cluster code cannot find
> a free cluster. Then, vm_swap_full() is not only condition to allow
> the kernel to reclaim unused swap.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good, except the now changed behaviour where swap will get
distributed between clusters. Having the vm_swap_full() is a good
optimization for swap allocation performance though. I'd say lets wait
to see the results of testing


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
