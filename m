Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1L9Wpl4025706
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 15:02:51 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1L9WpDk868432
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 15:02:51 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1L9WuZW032289
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 09:32:56 GMT
Message-ID: <47BD4438.4030203@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2008 14:58:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <47BC10A8.4020508@linux.vnet.ibm.com> <20080221.114929.42336527.taka@valinux.co.jp> <20080221153536.09c28f44.kamezawa.hiroyu@jp.fujitsu.com> <20080221.180745.74279466.taka@valinux.co.jp> <20080221182156.63e5fc25.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080221182156.63e5fc25.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, hugh@veritas.com, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 21 Feb 2008 18:07:45 +0900 (JST)
> Hirokazu Takahashi <taka@valinux.co.jp> wrote:
>>> But we'll be able to archive  pfn <-> page_cgroup relationship using
>>> on-demand memmap style.
>>> (Someone mentioned about using radix-tree in other thread.)
>> My concern is this approach seems to require some spinlocks to protect the
>> radix-tree. 
> 
> Unlike file-cache, radix-tree enries are not frequently changed.
> Then we have a chance to cache recently used value to per_cpu area for avoiding
> radix_tree lock.
> 
> But yes. I'm afraid of lock contention very much. I'll find another lock-less way
> if necessary. One idea is map each area like sparsemem_vmemmap for 64bit systems.
> Now, I'm convinced that it will be complicated ;)
> 

The radix tree base is lockless (it uses RCU), so we might have a partial
solution to the locking problem. But it's unchartered territory, so no one knows.

> I'd like to start from easy way and see performance.
> 

Sure, please keep me in the loop as well.

> Thanks,
> -Kame


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
