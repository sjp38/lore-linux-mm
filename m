Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m9L6H1Qb007673
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:17:01 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9L6GsuX199946
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:16:54 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9L6GrNq022674
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 17:16:54 +1100
Message-ID: <48FD73CE.6070004@linux.vnet.ibm.com>
Date: Tue, 21 Oct 2008 11:46:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: memcg: Fix init/Kconfig documentation
References: <20081021055118.GA11429@balbir.in.ibm.com> <20081021151105.f13ec6d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081021151105.f13ec6d2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 21 Oct 2008 11:21:18 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> From: Balbir Singh <balbir@linux.vnet.ibm.com>
>> Date: Tue, 21 Oct 2008 11:12:45 +0530
>> Subject: [PATCH] memcg: Update Kconfig to remove the struct page overhead statement.
>>
>> The memory resource controller no longer has a struct page overhead
>> associated with it. The init/Kconfig help has been replaced with
>> something more suitable based on the current implementation.
>>
> Oh, this is my version..could you merge if this includes something good ?
> 
> ==
> Fixes menu help text for memcg-allocate-page-cgroup-at-boot.patch.
> 
> 
> Signed-off-by: KAMEZAWA hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>  init/Kconfig |   16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> Index: mmotm-2.6.27+/init/Kconfig
> ===================================================================
> --- mmotm-2.6.27+.orig/init/Kconfig
> +++ mmotm-2.6.27+/init/Kconfig
> @@ -401,16 +401,20 @@ config CGROUP_MEM_RES_CTLR
>  	depends on CGROUPS && RESOURCE_COUNTERS
>  	select MM_OWNER
>  	help
> -	  Provides a memory resource controller that manages both page cache and
> -	  RSS memory.
> +	  Provides a memory resource controller that manages both anonymous
> +	  memory and page cache. (See Documentation/controllers/memory.txt)
> 
>  	  Note that setting this option increases fixed memory overhead
> -	  associated with each page of memory in the system by 4/8 bytes
> -	  and also increases cache misses because struct page on many 64bit
> -	  systems will not fit into a single cache line anymore.
> +	  associated with each page of memory in the system. By this,
> +	  20(40)bytes/PAGE_SIZE on 32(64)bit system will be occupied by memory
> +	  usage tracking struct at boot. Total amount of this is printed out
> +	  at boot.
> 
>  	  Only enable when you're ok with these trade offs and really
> -	  sure you need the memory resource controller.
> +	  sure you need the memory resource controller. Even when you enable
> +	  this, you can set "cgroup_disable=memory" at your boot option to
> +	  disable memory resource controller and you can avoid almost all bads.
							       ^^^^ (replace)
							       the overhead

> +	  (and lost benefits of memory resource contoller)
               ^^^^
		lose

> 
>  	  This config option also selects MM_OWNER config option, which
>  	  could in turn add some fork/exit overhead.
> 

Looks good otherwise.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
