Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJ6LIsD018558
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 01:21:18 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAJ6LHXp125718
	for <linux-mm@kvack.org>; Sun, 18 Nov 2007 23:21:18 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJ6LHEi029624
	for <linux-mm@kvack.org>; Sun, 18 Nov 2007 23:21:17 -0700
Message-ID: <47412B5B.80409@linux.vnet.ibm.com>
Date: Mon, 19 Nov 2007 11:51:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [9/10]
 per-zone-lru for memory cgroup
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com> <20071116192642.8c7f07c9.kamezawa.hiroyu@jp.fujitsu.com> <473F2A1A.8000703@linux.vnet.ibm.com> <20071119104826.e4ba02ca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071119104826.e4ba02ca.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "containers@lists.osdl.org" <containers@lists.osdl.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sat, 17 Nov 2007 23:21:22 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Thanks, this has been a long pending TODO. What is pending now on my
>> plate is re-organizing res_counter to become aware of the filesystem
>> hierarchy. I want to split out the LRU lists from the memory controller
>> and resource counters.
>>
> Does "file system hierarchy" here means "control group hierarchy" ?
> like

Yes, you are right

> =
> /cgroup/group_A/group_A_1
>             .  /group_A_2
>                /group_A_3
> (LRU(s) will be used for maintaining parent/child groups.)
> 

The LRU's will be shared, my vision is

		LRU
		^ ^
		| |
	Mem-----+ +----Mem


That two or more mem_cgroup's can refer to the same LRU list and have
their own resource counters. This setup will be used in the case
of a hierarchy, so that a child can share memory with its parent
and have it's own limit.

The mem_cgroup will basically then only contain a reference
to the LRU list.

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
