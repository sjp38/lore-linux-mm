Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7A10A6B003D
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 12:55:56 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2TGdfjh030545
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 03:39:41 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2TGuxHg790738
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 03:56:59 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2TGufQp007450
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 03:56:41 +1100
Date: Sun, 29 Mar 2009 22:26:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/8] memcg soft limit priority array queue.
Message-ID: <20090329165620.GB15608@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090327135933.789729cb.kamezawa.hiroyu@jp.fujitsu.com> <20090327140653.a12c6b1e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090327140653.a12c6b1e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-27 14:06:53]:

> I'm now search a way to reduce lock contention without complex...
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> +static void __mem_cgroup_requeue(struct mem_cgroup *mem)
> +{
> +	/* enqueue to softlimit queue */
> +	int prio = mem->soft_limit_priority;
> +
> +	spin_lock(&softlimitq.lock);
> +	list_del_init(&mem->soft_limit_anon);
> +	list_add_tail(&mem->soft_limit_anon, &softlimitq.queue[prio][SL_ANON]);
> +	list_del_init(&mem->soft_limit_file,ist[SL_FILE]);

Patch fails to build here, what is ist?

> +	list_add_tail(&mem->soft_limit_file, &softlimitq.queue[prio][SL_FILE]);
> +	spin_unlock(&softlimitq.lock);
> +}
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
