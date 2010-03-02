Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7FA6B0078
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 23:54:39 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp03.au.ibm.com (8.14.3/8.13.1) with ESMTP id o224pTmi020075
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 15:51:29 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o224sYTE1798170
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 15:54:34 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o224sY6Z007248
	for <linux-mm@kvack.org>; Tue, 2 Mar 2010 15:54:34 +1100
Date: Tue, 2 Mar 2010 10:24:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch -mm v2 01/10] oom: filter tasks not sharing the same
 cpuset
Message-ID: <20100302045432.GC3212@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002261550030.30830@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002261550030.30830@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-02-26 15:53:02]:

> Tasks that do not share the same set of allowed nodes with the task that
> triggered the oom should not be considered as candidates for oom kill.
> 
> Tasks in other cpusets with a disjoint set of mems would be unfairly
> penalized otherwise because of oom conditions elsewhere; an extreme
> example could unfairly kill all other applications on the system if a
> single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> more memory than allowed.
> 
> Killing tasks outside of current's cpuset rarely would free memory for
> current anyway.  To use a sane heuristic, we must ensure that killing a
> task would likely free memory for current and avoid needlessly killing
> others at all costs just because their potential memory freeing is
> unknown.  It is better to kill current than another task needlessly.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Nick Piggin <npiggin@suse.de>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
