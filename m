Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE206B004D
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 11:10:15 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7SFADkp016550
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 20:40:13 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7SFADTo2257028
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 20:40:13 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7SFADPO000789
	for <linux-mm@kvack.org>; Sat, 29 Aug 2009 01:10:13 +1000
Date: Fri, 28 Aug 2009 20:40:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/5] memcg: uncharge in batched manner
Message-ID: <20090828151011.GS4889@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090828132015.10a42e40.kamezawa.hiroyu@jp.fujitsu.com> <20090828132438.b33828bc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090828132438.b33828bc.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-08-28 13:24:38]:

> 
> In massive parallel enviroment, res_counter can be a performance bottleneck.
> This patch is a trial for reducing lock contention.
> One strong techinque to reduce lock contention is reducing calls by
> batching some amount of calls int one.
> 
> Considering charge/uncharge chatacteristic,
> 	- charge is done one by one via demand-paging.
> 	- uncharge is done by
> 		- in chunk at munmap, truncate, exit, execve...
> 		- one by one via vmscan/paging.
> 
> It seems we hace a chance to batched-uncharge.
> This patch is a base patch for batched uncharge. For avoiding
> scattering memcg's structure, this patch adds memcg batch uncharge
> information to the task. please see start/end usage in next patch.
>

Overall it is a very good idea, can't we do the uncharge at the poin
tof unmap_vmas, exit_mmap, etc so that we don't have to keep
additional data structures around. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
