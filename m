Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2B4jwZ3027992
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 15:45:58 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2B4nUqx047438
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 15:49:30 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2B4jloA013286
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 15:45:48 +1100
Message-ID: <47D60E74.6080109@linux.vnet.ibm.com>
Date: Tue, 11 Mar 2008 10:15:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Move memory controller allocations to their own slabs
References: <20080311043149.20251.50059.sendpatchset@localhost.localdomain> <20080310214100.d7fe7904.akpm@linux-foundation.org>
In-Reply-To: <20080310214100.d7fe7904.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 11 Mar 2008 10:01:49 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>
>> Move the memory controller data structures page_cgroup and
>> mem_cgroup_per_zone to their own slab caches. It saves space on the system,
>> allocations are not necessarily pushed to order of 2 and should provide
>> performance benefits.
> 
> eh?  Those structures are tiny.  Which slab allocator has gone and used an
> order-2 allocation and for which structure did it (stupidly) do this?
> 
> 

When I say order of 2, I meant with kmalloc. They are rounded of to 64, 128 byte
boundary. I wanted to pack these objects more closely.

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
