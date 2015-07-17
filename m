Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 18AA46B02B0
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:10:50 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so77250792wgx.3
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 02:10:49 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id lg1si18437657wjc.136.2015.07.17.02.10.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 02:10:48 -0700 (PDT)
Date: Fri, 17 Jul 2015 11:10:11 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2] mem-hotplug: Handle node hole when initializing
 numa_meminfo.
In-Reply-To: <1437096211-28605-3-git-send-email-tangchen@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.11.1507171107540.18576@nanos>
References: <1437096211-28605-1-git-send-email-tangchen@cn.fujitsu.com> <1437096211-28605-3-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, dyoung@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com, lcapitulino@redhat.com, qiuxishi@huawei.com, will.deacon@arm.com, tony.luck@intel.com, vladimir.murzin@arm.com, fabf@skynet.be, kuleshovmail@gmail.com, bhe@redhat.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 17 Jul 2015, Tang Chen wrote:
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index d312ae3..c518eb5 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -77,6 +77,8 @@ int memblock_remove(phys_addr_t base, phys_addr_t size);
>  int memblock_free(phys_addr_t base, phys_addr_t size);
>  int memblock_reserve(phys_addr_t base, phys_addr_t size);
>  void memblock_trim_memory(phys_addr_t align);
> +bool memblock_overlaps_region(struct memblock_type *type,
> +			      phys_addr_t base, phys_addr_t size);
  
> -static bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
> +bool __init_memblock memblock_overlaps_region(struct memblock_type *type,
>  					phys_addr_t base, phys_addr_t size)
>  {
>  	unsigned long i;

This is silly. You change that function in the first patch already, so
why don't you make it globally visible there and then have the user.

Other than that:

Acked-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
