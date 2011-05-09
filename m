Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7C76B0012
	for <linux-mm@kvack.org>; Mon,  9 May 2011 04:28:23 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p498MMrE032321
	for <linux-mm@kvack.org>; Mon, 9 May 2011 18:22:22 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p498SIxa1143016
	for <linux-mm@kvack.org>; Mon, 9 May 2011 18:28:18 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p498SJ73032060
	for <linux-mm@kvack.org>; Mon, 9 May 2011 18:28:20 +1000
Date: Mon, 9 May 2011 13:58:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] Allocate memory cgroup structures in local nodes v4
Message-ID: <20110509082801.GD2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1304716637-19556-1-git-send-email-andi@firstfloor.org>
 <1304716637-19556-2-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1304716637-19556-2-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, rientjes@google.com, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>

* Andi Kleen <andi@firstfloor.org> [2011-05-06 14:17:17]:

> From: Andi Kleen <ak@linux.intel.com>
> 
> dde79e005a769 added a regression that the memory cgroup data structures
> all end up in node 0 because the first attempt at allocating them
> would not pass in a node hint. Since the initialization runs on CPU #0
> it would all end up node 0. This is a problem on large memory systems,
> where node 0 would lose a lot of memory.
> 
> Change the alloc_pages_exact to alloc_pages_exact_node. This will
                                                       ^ should be nid
> still fall back to other nodes if not enough memory is available.
> 
> [RED-PEN: right now it would fall back first before trying
> vmalloc_node. Probably not the best strategy ... But I left it like
> that for now.]
> 
> v4: Remove debugging code.
> v3: Really call the correct function now. Thanks for everyone who commented.
> Reported-by: Doug Nelson
> Cc: rientjes@google.com
> CC: Michal Hocko <mhocko@suse.cz>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Balbir Singh <balbir@in.ibm.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
