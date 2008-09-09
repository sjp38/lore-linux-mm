Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m89CXIdx028940
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 22:33:18 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m89CYEq0249992
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 22:34:14 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m89CYDvh013610
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 22:34:13 +1000
Message-ID: <48C66D3E.5070602@linux.vnet.ibm.com>
Date: Tue, 09 Sep 2008 05:34:06 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <48C66AF8.5070505@linux.vnet.ibm.com> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809091358.28350.nickpiggin@yahoo.com.au> <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com> <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
>>> Balbir, are you ok to CONFIG_CGROUP_MEM_RES_CTLR depends on CONFIG_SPARSEME
> M ?
>>> I thinks SPARSEMEM(SPARSEMEM_VMEMMAP) is widely used in various archs now.
>> Can't we make it more generic. I was thinking of allocating memory for each n
> ode
>> for page_cgroups (of the size of spanned_pages) at initialization time. I've 
> not
>> yet prototyped the idea. BTW, even with your approach I fail to see why we ne
> ed
>> to add a dependency on CONFIG_SPARSEMEM (but again it is 4:30 in the morning 
> and
>> I might be missing the obvious)
> 
> Doesn't have big issue without CONFIG_SPARSEMEM, maybe.
> Sorry for my confusion.

No problem, I am glad to know that we are not limited to a particular model.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
