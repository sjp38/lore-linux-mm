Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8B82E6B0256
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 04:53:37 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so63454130wml.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 01:53:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wd3si18125530wjc.88.2016.03.07.01.53.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 01:53:36 -0800 (PST)
Subject: Re: [PATCH] mm: ZONE_DEVICE depends on SPARSEMEM_VMEMMAP
References: <20160305004214.12356.32017.stgit@dwillia2-desk3.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DD4F9F.303@suse.cz>
Date: Mon, 7 Mar 2016 10:53:35 +0100
MIME-Version: 1.0
In-Reply-To: <20160305004214.12356.32017.stgit@dwillia2-desk3.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/05/2016 01:42 AM, Dan Williams wrote:
> The primary use case for devm_memremap_pages() is to allocate an
> memmap array from persistent memory.  That capabilty requires
> vmem_altmap which requires SPARSEMEM_VMEMMAP.

Some if the ifdefs around to_vmem_altmap() could now be simplified, but 
that can also be done later...

> Also, without SPARSEMEM_VMEMMAP the addition of ZONE_DEVICE expands
> ZONES_WIDTH and triggers the:
>
> "Unfortunate NUMA and NUMA Balancing config, growing page-frame for
> last_cpupid."
>
> ...warning in mm/memory.c.  SPARSEMEM_VMEMMAP=n && ZONE_DEVICE=y is not
> a configuration we should worry about supporting.
>
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/Kconfig |    1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 664fa2416909..b95322ba542b 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -654,6 +654,7 @@ config ZONE_DEVICE
>   	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
>   	depends on MEMORY_HOTPLUG
>   	depends on MEMORY_HOTREMOVE
> +	depends on SPARSEMEM_VMEMMAP
>   	depends on X86_64 #arch_add_memory() comprehends device memory
>
>   	help
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
