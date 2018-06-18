Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6E06B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:15:15 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x32-v6so10432597pld.16
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:15:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g10-v6si12159919pge.676.2018.06.18.10.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Jun 2018 10:15:13 -0700 (PDT)
Subject: Re: [PATCH 05/11] docs/mm: bootmem: add overview documentation
References: <1529341199-17682-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1529341199-17682-6-git-send-email-rppt@linux.vnet.ibm.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <fb7be5ca-1c39-0ba1-cf17-92dabee947ad@infradead.org>
Date: Mon, 18 Jun 2018 10:15:10 -0700
MIME-Version: 1.0
In-Reply-To: <1529341199-17682-6-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Hi,

On 06/18/2018 09:59 AM, Mike Rapoport wrote:
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
>  mm/bootmem.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 47 insertions(+)
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 76fc17e..423cb5f 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -21,6 +21,53 @@
>  
>  #include "internal.h"
>  
> +/**
> + * DOC: bootmem overview
> + *
> + * Bootmem is a boot-time physical memory allocator and configurator.
> + *
> + * It is used early in the boot process before the page allocator is
> + * set up.
> + *
> + * The bootmem is based on the most basic of allocators, a First Fit

    * Bootmem is based on
or
    * The bootmem allocator is based on

> + * allocator which uses a bitmap to represent memory. If a bit is 1,
> + * the page is allocated and 0 if unallocated. To satisfy allocations
> + * of sizes smaller than a page, the allocator records the Page Frame
> + * Number (PFN) of the last allocation and the offset the allocation
> + * ended at. Subsequent small allocations are merged together and
> + * stored on the same page.


-- 
~Randy
