Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1KCu1hc015038
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 23:56:01 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1KD01gZ216898
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 00:00:01 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1KCuNxu016645
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 23:56:23 +1100
Message-ID: <47BC2275.4060900@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 18:22:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org>
In-Reply-To: <20080220122338.GA4352@basil.nowhere.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Document huge memory/cache overhead of memory controller in Kconfig
> 
> I was a little surprised that 2.6.25-rc* increased struct page for the memory
> controller.  At least on many x86-64 machines it will not fit into a single
> cache line now anymore and also costs considerable amounts of RAM. 

The size of struct page earlier was 56 bytes on x86_64 and with 64 bytes it
won't fit into the cacheline anymore? Please also look at
http://lwn.net/Articles/234974/

> At earlier review I remembered asking for a external data structure for this.
> 
> It's also quite unobvious that a innocent looking Kconfig option with a 
> single line Kconfig description has such a negative effect.
> 
> This patch attempts to document these disadvantages at least so that users
> configuring their kernel can make a informed decision.
> 
> Cc: balbir@linux.vnet.ibm.com
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> Index: linux/init/Kconfig
> ===================================================================
> --- linux.orig/init/Kconfig
> +++ linux/init/Kconfig
> @@ -394,6 +394,14 @@ config CGROUP_MEM_CONT
>  	  Provides a memory controller that manages both page cache and
>  	  RSS memory.
> 
> +	  Note that setting this option increases fixed memory overhead
> +	  associated with each page of memory in the system by 4/8 bytes
> +	  and also increases cache misses because struct page on many 64bit
> +	  systems will not fit into a single cache line anymore.
> +
> +	  Only enable when you're ok with these trade offs and really
> +	  sure you need the memory controller.
> +

Looks good

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

>  config PROC_PID_CPUSET
>  	bool "Include legacy /proc/<pid>/cpuset file"
>  	depends on CPUSETS


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
