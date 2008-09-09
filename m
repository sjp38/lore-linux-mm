Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m894IjGM016112
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 14:18:45 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m894JewP194406
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 14:19:54 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m894JdMG014254
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 14:19:40 +1000
Message-ID: <48C5F91D.5070500@linux.vnet.ibm.com>
Date: Mon, 08 Sep 2008 21:18:37 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809011743.42658.nickpiggin@yahoo.com.au> <48BD0641.4040705@linux.vnet.ibm.com> <20080902190256.1375f593.kamezawa.hiroyu@jp.fujitsu.com> <48BD0E4A.5040502@linux.vnet.ibm.com> <20080902190723.841841f0.kamezawa.hiroyu@jp.fujitsu.com> <48BD119B.8020605@linux.vnet.ibm.com> <20080902195717.224b0822.kamezawa.hiroyu@jp.fujitsu.com> <48BD337E.40001@linux.vnet.ibm.com> <20080903123306.316beb9d.kamezawa.hiroyu@jp.fujitsu.com> <20080908152810.GA12065@balbir.in.ibm.com> <20080909125751.37042345.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080909125751.37042345.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 8 Sep 2008 20:58:10 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Sorry for the delay in sending out the new patch, I am traveling and
>> thus a little less responsive. Here is the update patch
>>
>>
> Hmm.. I've considered this approach for a while and my answer is that
> this is not what you really want.
> 
> Because you just moves the placement of pointer from memmap to
> radix_tree both in GFP_KERNEL, total kernel memory usage is not changed.

Agreed, but we do reduce the sizeof(struct page) without adding on to
page_cgroup's size. So why don't we want this?

> So, at least, you have to add some address calculation (as I did in March)
> to getting address of page_cgroup.

What address calculation do we need, sorry I don't recollect it.

 But page_cgroup itself consumes 32bytes
> per page. Then.....
> 
> My proposal to 32bit system is following 
>  - remove page_cgroup completely.
>    - As a result, there is no per-cgroup lru. But it will not be bad
>      bacause the number of cgroups and pages are not big.
>      just a trade-off between kernel-memory-space v.s. speed.

32 bit systems with PAE can support quite a lot of memory, so I am not sure I
agree. I don't like this approach

>    - Removing page_cgroup and just remember address of mem_cgroup per page.
> 

This is on top of the suggested approach above?

> How do you think ?
> 

I don't like the approach.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
