Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2B8Fo9J021575
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 13:45:50 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2B8Fo7x1138830
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 13:45:50 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2B8FnBB027723
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 08:15:50 GMT
Message-ID: <47D63FB1.7040502@linux.vnet.ibm.com>
Date: Tue, 11 Mar 2008 13:45:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Move memory controller allocations to their own slabs
 (v2)
References: <20080311061836.6664.5072.sendpatchset@localhost.localdomain> <47D63E9D.70500@openvz.org>
In-Reply-To: <47D63E9D.70500@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> Balbir Singh wrote:
>> Move the memory controller data structure page_cgroup to its own slab cache.
>> It saves space on the system, allocations are not necessarily pushed to order
>> of 2 and should provide performance benefits. Users who disable the memory
>> controller can also double check that the memory controller is not allocating
>> page_cgroup's.
> 
> Can you, please, check how many objects-per-page we have with and 
> without this patch for SLAB and SLUB?
> 
> Thanks.

I can for objects-per-page with this patch for SLUB and SLAB. I am not sure
about what to check for without this patch. The machine is temporarily busy,
I'll check it once I get it back.

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
