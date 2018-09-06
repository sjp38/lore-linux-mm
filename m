Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65DCA6B7780
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 03:53:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c16-v6so3346771edc.21
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:53:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 53-v6si3964955edu.227.2018.09.06.00.53.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 00:53:20 -0700 (PDT)
Date: Thu, 6 Sep 2018 09:53:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 11/29] memblock: replace alloc_bootmem_pages_nopanic
 with memblock_alloc_nopanic
Message-ID: <20180906075319.GT14951@dhcp22.suse.cz>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1536163184-26356-12-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536163184-26356-12-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 05-09-18 18:59:26, Mike Rapoport wrote:
> The alloc_bootmem_pages_nopanic(size) is a shortcut for
> __alloc_bootmem_nopanic(x, PAGE_SIZE, BOOTMEM_LOW_LIMIT) and can be
> replaced by memblock_alloc_nopanic(size, PAGE_SIZE)

It is not so straightforward because you really have to go deep down the
callpath to see they are doing the same thing essentially.

> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/usb/early/xhci-dbc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/usb/early/xhci-dbc.c b/drivers/usb/early/xhci-dbc.c
> index e15e896..16df968 100644
> --- a/drivers/usb/early/xhci-dbc.c
> +++ b/drivers/usb/early/xhci-dbc.c
> @@ -94,7 +94,7 @@ static void * __init xdbc_get_page(dma_addr_t *dma_addr)
>  {
>  	void *virt;
>  
> -	virt = alloc_bootmem_pages_nopanic(PAGE_SIZE);
> +	virt = memblock_alloc_nopanic(PAGE_SIZE, PAGE_SIZE);
>  	if (!virt)
>  		return NULL;
>  
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
