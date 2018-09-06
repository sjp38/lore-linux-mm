Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66EFD6B77AC
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 03:57:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g29-v6so3370913edb.1
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:57:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t9-v6si4042437edm.50.2018.09.06.00.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 00:57:22 -0700 (PDT)
Date: Thu, 6 Sep 2018 09:57:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 13/29] memblock: replace __alloc_bootmem_nopanic with
 memblock_alloc_from_nopanic
Message-ID: <20180906075721.GV14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-14-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536163184-26356-14-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:28, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

The translation is simpler here but still a word or two would be nice.
Empty changelogs suck.

To the change
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/arc/kernel/unwind.c       | 4 ++--
>  arch/x86/kernel/setup_percpu.c | 4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/arc/kernel/unwind.c b/arch/arc/kernel/unwind.c
> index 183391d..2a01dd1 100644
> --- a/arch/arc/kernel/unwind.c
> +++ b/arch/arc/kernel/unwind.c
> @@ -181,8 +181,8 @@ static void init_unwind_hdr(struct unwind_table *table,
>   */
>  static void *__init unw_hdr_alloc_early(unsigned long sz)
>  {
> -	return __alloc_bootmem_nopanic(sz, sizeof(unsigned int),
> -				       MAX_DMA_ADDRESS);
> +	return memblock_alloc_from_nopanic(sz, sizeof(unsigned int),
> +					   MAX_DMA_ADDRESS);
>  }
>  
>  static void *unw_hdr_alloc(unsigned long sz)
> diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
> index 67d48e26..041663a 100644
> --- a/arch/x86/kernel/setup_percpu.c
> +++ b/arch/x86/kernel/setup_percpu.c
> @@ -106,7 +106,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
>  	void *ptr;
>  
>  	if (!node_online(node) || !NODE_DATA(node)) {
> -		ptr = __alloc_bootmem_nopanic(size, align, goal);
> +		ptr = memblock_alloc_from_nopanic(size, align, goal);
>  		pr_info("cpu %d has no node %d or node-local memory\n",
>  			cpu, node);
>  		pr_debug("per cpu data for cpu%d %lu bytes at %016lx\n",
> @@ -121,7 +121,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
>  	}
>  	return ptr;
>  #else
> -	return __alloc_bootmem_nopanic(size, align, goal);
> +	return memblock_alloc_from_nopanic(size, align, goal);
>  #endif
>  }
>  
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
