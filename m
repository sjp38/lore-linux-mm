Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l99AWjun026035
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:32:45 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99AZ4UC140576
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:35:04 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99AVDDf007742
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:31:13 +1000
Message-ID: <470B585F.9040207@linux.vnet.ibm.com>
Date: Tue, 09 Oct 2007 16:00:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [0/6]
 intro
References: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, Balbir-san
> This is a patch set against memory cgroup I have now.
> Reflected comments I got.
> 
> = 
> [1] charge refcnt fix patch     - avoid charging against a page which is being 
>                                   uncharged.
> [2] fix-err-handling patch      - remove unnecesary unlock_page_cgroup()
> [3] lock and page->cgroup patch - add helper function for charge/uncharge
> [4] avoid handling no LRU patch - makes mem_cgroup_isolate_pages() avoid
>                                   handling !Page_LRU pages.
> [5] migration fix patch         - a fix for page migration.
> [6] force reclaim patch         - add an interface for uncharging all pages in
>                                   empty cgroup.
> =
> 

Thank you very much for working on this.

> BTW, which way would you like to go ?
> 
>   1. You'll merge this set (and my future patch) to your set as
>      Memory Cgroup Maintainer and pass to Andrew Morton, later.
>      And we'll work against your tree.
>   2. I post this set to the (next) -mm. And we'll work agaisnt -mm.
> 

I think (2) is better. I don't maintain my own tree, so lets get
all the fixes and enhancements into -mm

> not as my usual patch, tested on x86-64 fake-NUMA.
> 

I'll also test these patches.

> Thanks,
> -Kame
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
