Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD8276B007E
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 11:48:58 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6KFlP9V014334
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 09:47:25 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6KFn1LZ257458
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 09:49:01 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6KFn1me003168
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 09:49:01 -0600
Date: Mon, 20 Jul 2009 21:18:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/5] Memory controller soft limit patches (v9)
Message-ID: <20090720154859.GI24157@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090710125950.5610.99139.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2009-07-10 18:29:50]:

> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> New Feature: Soft limits for memory resource controller.
> 
> Here is v9 of the new soft limit implementation. Soft limits is a new feature
> for the memory resource controller, something similar has existed in the
> group scheduler in the form of shares. The CPU controllers interpretation
> of shares is very different though. 
> 
> Soft limits are the most useful feature to have for environments where
> the administrator wants to overcommit the system, such that only on memory
> contention do the limits become active. The current soft limits implementation
> provides a soft_limit_in_bytes interface for the memory controller and not
> for memory+swap controller. The implementation maintains an RB-Tree of groups
> that exceed their soft limit and starts reclaiming from the group that
> exceeds this limit by the maximum amount.
> 
> v9 attempts to address several review comments for v8 by Kamezawa, including
> moving over to an event based approach for soft limit rb tree management,
> simplification of data structure names and many others. Comments not
> addressed have been answered via email or I've added comments in the code.
> 
> TODOs
> 
> 1. The current implementation maintains the delta from the soft limit
>    and pushes back groups to their soft limits, a ratio of delta/soft_limit
>    might be more useful
> 


Hi, Andrew,

Could you please pick up this patchset for testing in -mm, both
Kamezawa-San and Kosaki-San have looked at the patches. I think they
are ready for testing in mmotm.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
