Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9BJvCIP022605
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 05:57:12 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9BJvDOo4890644
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 05:57:13 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9BJuuC7031482
	for <linux-mm@kvack.org>; Fri, 12 Oct 2007 05:56:57 +1000
Message-ID: <470E7FFE.6020309@linux.vnet.ibm.com>
Date: Fri, 12 Oct 2007 01:26:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][BUGFIX][for -mm] Misc fix for memory cgroup [0/5]
References: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This set is a fix for memory cgroup against 2.6.23-rc8-mm2.
> Not including any new feature.
> 
> If this is merged to the next -mm, I'm happy.
> 
> Patches:
> [1/5] ... fix refcnt handling in charge mem_cgroup_charge()
> [2/5] ... fix error handling path in mem_cgroup_charge()
> [3/5] ... check page->cgroup under lock again.
> [4/5] ... fix mem_cgroup_isolate_pages() to skip !PageLRU() pages.
> [5/5] ... fix page migration under memory controller, fixes leak.
> 
> Changes from previous ones.
>  -- dropped new feature.... force_empty patch. It will be posted later.
>  -- fix typos
>  -- added comments
> 
> Tested on x86-64/fake-NUMA system.
> 

I tested the patches, ran kernbench, lmbench and some tests with
parallel containers. Except for the one typo in the page migration
patch, the patches worked quite well. KAMEZAWA-San, could you please
send the updated patch with the compilation fix.

I am yet to test the migration fix (I am yet to get access to a NUMA/
box capable of fake NUMA). I have not measured the performance impact
of these patches.

Andrew, could you please consider these patches for -mm inclusion once
KAMEZAWA-San sends out the fixed migration patch.

> Thanks,
> -Kame
> 
> 
> 
> 
> 


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
