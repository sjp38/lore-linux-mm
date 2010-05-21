Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5017D6B01BC
	for <linux-mm@kvack.org>; Fri, 21 May 2010 06:11:28 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id o4LABCrK015682
	for <linux-mm@kvack.org>; Fri, 21 May 2010 20:11:12 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4LABOqB1892566
	for <linux-mm@kvack.org>; Fri, 21 May 2010 20:11:24 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o4LABNle011106
	for <linux-mm@kvack.org>; Fri, 21 May 2010 20:11:24 +1000
Date: Fri, 21 May 2010 15:41:04 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [RFC, 6/7] NUMA hotplug emulator
Message-ID: <20100521101104.GB7906@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <20100513120016.GG2169@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513120016.GG2169@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Greg Kroah-Hartman <gregkh@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 13, 2010 at 08:00:16PM +0800, Shaohui Zheng wrote:
> hotplug emulator:extend memory probe interface to support NUMA
> 
> Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> Signed-off-by: Haicheng Li <haicheng.li@intel.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 54ccb0d..787024f 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1239,6 +1239,17 @@ config ARCH_CPU_PROBE_RELEASE
>  	  is for cpu hot-add/hot-remove to specified node in software method.
>  	  This is for debuging and testing purpose
> 
> +config ARCH_MEMORY_PROBE

The above symbol exists already...

> +	def_bool y
> +	bool "Memory hotplug emulation"
> +	depends on NUMA_HOTPLUG_EMU
> +	---help---
> +	  Enable memory hotplug emulation. Reserve memory with grub parameter
> +	  "mem=N"(such as mem=1024M), where N is the initial memory size, the
> +	  rest physical memory will be removed from e820 table; the memory probe
> +	  interface is for memory hot-add to specified node in software method.
> +	  This is for debuging and testing purpose
> +
>  config NODES_SHIFT
>  	int "Maximum NUMA Nodes (as a power of 2)" if !MAXSMP
>  	range 1 10


-- 
Regards,                                                                        
Ankita Garg (ankita@in.ibm.com)                                                 
Linux Technology Center                                                         
IBM India Systems & Technology Labs,                                            
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
