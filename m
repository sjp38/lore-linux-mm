Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1A26B006A
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 05:51:24 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0FApH4g015897
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:21:17 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0FApLVG2396200
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 16:21:21 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0FApGfX023680
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 21:51:17 +1100
Date: Thu, 15 Jan 2009 16:21:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] cgroup/memcg : updates related to CSS
Message-ID: <20090115105116.GG30358@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-15 19:21:20]:

> 
> I'm sorry that I couldn't work so much, this week.
> No much updates but I think all comments I got are applied.
> 
> About memcg part, I'll wait for that all Nishimura's fixes go ahead.
> If cgroup part looks good, please Ack. I added CC to Andrew Morton for that part.
> 
> changes from previous series
>   - dropeed a fix to OOM KILL   (will reschedule)
>   - dropped a fix to -EBUSY     (will reschedule)
>   - added css_is_populated()
>   - added hierarchy_stat patch
> 
> Known my homework is
>   - resize_limit should return -EBUSY. (Li Zefan reported.)
> 
> Andrew, I'll CC: you [1/4] and [2/4]. But no explicit Acked-by yet to any patches.
>

Kamezawa-San, like you've suggested earlier, I think it is important
to split up the fixes from the development patches. I wonder if we
should start marking all patches with BUGFIX for bug fixes, so that we
can prioritize those first.
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
