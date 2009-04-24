Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B7EC06B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 08:25:15 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp08.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3ONLUFL007404
	for <linux-mm@kvack.org>; Sat, 25 Apr 2009 09:21:30 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3OCPUVs512068
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 22:25:32 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3OCPUvk027527
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 22:25:30 +1000
Date: Fri, 24 Apr 2009 17:54:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/9] memcg soft limit v2 (new design)
Message-ID: <20090424122441.GD3944@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-03 17:08:35]:

> Hi,
> 
> Memory cgroup's soft limit feature is a feature to tell global LRU 
> "please reclaim from this memcg at memory shortage".
> 
> This is v2. Fixed some troubles under hierarchy. and increase soft limit
> update hooks to proper places.
> 
> This patch is on to
>   mmotom-Mar23 + memcg-cleanup-cache_charge.patch
>   + vmscan-fix-it-to-take-care-of-nodemask.patch
> 
> So, not for wide use ;)
> 
> This patch tries to avoid to use existing memcg's reclaim routine and
> just tell "Hints" to global LRU. This patch is briefly tested and shows
> good result to me. (But may not to you. plz brame me.)
> 
> Major characteristic is.
>  - memcg will be inserted to softlimit-queue at charge() if usage excess
>    soft limit.
>  - softlimit-queue is a queue with priority. priority is detemined by size
>    of excessing usage.
>  - memcg's soft limit hooks is called by shrink_xxx_list() to show hints.
>  - Behavior is affected by vm.swappiness and LRU scan rate is determined by
>    global LRU's status.
> 
> In this v2.
>  - problems under use_hierarchy=1 case are fixed.
>  - more hooks are added.
>  - codes are cleaned up.
>

The results seem good so far with some basic tests I've been doing.
I'll come back with more feedback, I would like to see this feature in
-mm soon.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
