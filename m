Subject: Re: [RFC][2/3] Account and control virtual address space allocations
In-Reply-To: Your message of "Sun, 16 Mar 2008 23:00:05 +0530"
	<20080316173005.8812.88290.sendpatchset@localhost.localdomain>
References: <20080316173005.8812.88290.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080317233552.4A7E21E7CE6@siro.lan>
Date: Tue, 18 Mar 2008 08:35:52 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, rientjes@google.com, xemul@openvz.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> diff -puN mm/swapfile.c~memory-controller-virtual-address-space-accounting-and-control mm/swapfile.c
> diff -puN mm/memory.c~memory-controller-virtual-address-space-accounting-and-control mm/memory.c
> --- linux-2.6.25-rc5/mm/memory.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
> +++ linux-2.6.25-rc5-balbir/mm/memory.c	2008-03-16 22:57:40.000000000 +0530
> @@ -838,6 +838,11 @@ unsigned long unmap_vmas(struct mmu_gath
>  
>  		if (vma->vm_flags & VM_ACCOUNT)
>  			*nr_accounted += (end - start) >> PAGE_SHIFT;
> +		/*
> +		 * Unaccount used virtual memory for cgroups
> +		 */
> +		mem_cgroup_update_as(vma->vm_mm,
> +					((long)(start - end)) >> PAGE_SHIFT);
>  
>  		while (start != end) {
>  			if (!tlb_start_valid) {

i think you can sum and uncharge it with a single call.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
