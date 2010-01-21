Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA16B6B007E
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:29:56 -0500 (EST)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp03.au.ibm.com (8.14.3/8.13.1) with ESMTP id o0LFQu0b029185
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 02:26:56 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0LFP6bx1523856
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 02:25:06 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0LFTp0E020694
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 02:29:51 +1100
Message-ID: <4B5872EC.5040603@linux.vnet.ibm.com>
Date: Thu, 21 Jan 2010 20:59:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] oom-kill: add lowmem usage aware oom kill handling
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thursday 21 January 2010 11:29 AM, KAMEZAWA Hiroyuki wrote:
> A patch for avoiding oom-serial-killer at lowmem shortage.
> Patch is onto mmotm-2010/01/15 (depends on mm-count-lowmem-rss.patch)
> Tested on x86-64/SMP + debug module(to allocated lowmem), works well.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> One cause of OOM-Killer is memory shortage in lower zones.
> (If memory is enough, lowmem_reserve_ratio works well. but..)
> 
> In lowmem-shortage oom-kill, oom-killer choses a vicitim process
> on their vm size. But this kills a process which has lowmem memory
> only if it's lucky. At last, there will be an oom-serial-killer.
> 
> Now, we have per-mm lowmem usage counter. We can make use of it
> to select a good? victim.

Have you seen any use cases that need this change? Or is it mostly via
code review and to utilize the availability of lowmem rss? Do we often
run into lowmem shortage triggering OOM?


-- 
Three Cheers,
Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
