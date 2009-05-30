Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 96FA46B0098
	for <linux-mm@kvack.org>; Sat, 30 May 2009 03:20:17 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4U7HitE029118
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:17:44 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4U7KYfC247586
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:20:35 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4U7KYrg019848
	for <linux-mm@kvack.org>; Sat, 30 May 2009 01:20:34 -0600
Date: Sat, 30 May 2009 15:20:30 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] memcg: fix swap accounting
Message-ID: <20090530072030.GG24073@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com> <20090528142156.efa97a37.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090528142156.efa97a37.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-28 14:21:56]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch fixes mis-accounting of swap usage in memcg.
> 
> In current implementation, memcg's swap account is uncharged only when
> swap is completely freed. But there are several cases where swap
> cannot be freed cleanly. For handling that, this patch changes that
> memcg uncharges swap account when swap has no references other than cache.
> 
> By this, memcg's swap entry accounting can be fully synchronous with
> the application's behavior.
> This patch also changes memcg's hooks for swap-out.
>

Looks good, so for count == 0, we directly free the and uncharge, for
the others we use retry_to_use_swap(). cool!


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
