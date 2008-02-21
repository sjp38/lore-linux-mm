Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1L5pOi0015743
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 16:51:24 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1L5tGYk264418
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 16:55:16 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1L5pbe7017389
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 16:51:38 +1100
Message-ID: <47BD1052.2090204@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2008 11:16:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <200802211535.38932.nickpiggin@yahoo.com.au> <47BD06C2.5030602@linux.vnet.ibm.com> <200802211622.51751.nickpiggin@yahoo.com.au>
In-Reply-To: <200802211622.51751.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
>> 1. We could create something similar to mem_map, we would need to handle 4
> 
>> different ways of creating mem_map.
> 
>> 2. On x86 with 64 GB ram, if we decided to use vmalloc space, we would need
> 
>> 64 MB of vmalloc'ed memory
> 
> That's going to be a big job. You could probably do it quite easily for
> 
> flatmem (just store an offset into the start of your page array), and
> 
> maybe even sparsemem (add some "extra" information to the extents).
> 
>> I have not explored your latest suggestion of pfn <-> memory controller
> 
>> mapping yet. I'll explore it and see how that goes.
> 
> If you did that using a radix-tree, then it could be a runtime option
> 
> without having to use vmalloc. And you wouldn't have to care about
> 
> memory models. I'd say it will be the fastest way to get a prototype
> 
> running.
> 

OK, I'll explore and prototype the radix tree based approach and see how that goes.

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
