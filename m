Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A15756B7792
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 03:39:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k16-v6so3344200ede.6
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:39:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w8-v6si3673886edc.278.2018.09.06.00.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 00:39:32 -0700 (PDT)
Date: Thu, 6 Sep 2018 09:39:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 08/29] memblock: replace alloc_bootmem_align with
 memblock_alloc
Message-ID: <20180906073931.GQ14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-9-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536163184-26356-9-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:23, Mike Rapoport wrote:
> The functions are equivalent, just the later does not require nobootmem
> translation layer.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/x86/xen/p2m.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/xen/p2m.c b/arch/x86/xen/p2m.c
> index 159a897..68c0f14 100644
> --- a/arch/x86/xen/p2m.c
> +++ b/arch/x86/xen/p2m.c
> @@ -180,7 +180,7 @@ static void p2m_init_identity(unsigned long *p2m, unsigned long pfn)
>  static void * __ref alloc_p2m_page(void)
>  {
>  	if (unlikely(!slab_is_available()))
> -		return alloc_bootmem_align(PAGE_SIZE, PAGE_SIZE);
> +		return memblock_alloc(PAGE_SIZE, PAGE_SIZE);
>  
>  	return (void *)__get_free_page(GFP_KERNEL);
>  }
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
