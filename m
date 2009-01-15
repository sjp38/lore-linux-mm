Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 819C76B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:16:00 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0F6Ftem007935
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:45:55 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0F6E5d84300844
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:44:05 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0F6FsE2026513
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 17:15:55 +1100
Date: Thu, 15 Jan 2009 11:45:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
Message-ID: <20090115061557.GD30358@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <496ED2B7.5050902@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <496ED2B7.5050902@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Li Zefan <lizf@cn.fujitsu.com> [2009-01-15 14:07:51]:

> 1. task p1 is in /memcg/0
> 2. p1 does mmap(4096*2, MAP_LOCKED)
> 3. echo 4096 > /memcg/0/memory.limit_in_bytes
> 
> The above 'echo' will never return, unless p1 exited or freed the memory.
> The cause is we can't reclaim memory from p1, so the while loop in
> mem_cgroup_resize_limit() won't break.
> 
> This patch fixes it by decrementing retry_count regardless the return value
> of mem_cgroup_hierarchical_reclaim().
>

The problem definitely seems to exist, shouldn't we fix reclaim to
return 0, so that we know progress is not made and retry count
decrements? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
