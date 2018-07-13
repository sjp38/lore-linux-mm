Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F08C6B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 09:17:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f13-v6so6048263wmb.4
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 06:17:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u19-v6sor1683690wmc.34.2018.07.13.06.17.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 06:17:50 -0700 (PDT)
Date: Fri, 13 Jul 2018 15:17:49 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v5 1/5] mm/sparse: abstract sparse buffer allocations
Message-ID: <20180713131749.GA16765@techadventures.net>
References: <20180712203730.8703-1-pasha.tatashin@oracle.com>
 <20180712203730.8703-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712203730.8703-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Thu, Jul 12, 2018 at 04:37:26PM -0400, Pavel Tatashin wrote:
> +static void *sparsemap_buf __meminitdata;
> +static void *sparsemap_buf_end __meminitdata;
> +
> +void __init sparse_buffer_init(unsigned long size, int nid)
> +{
> +	BUG_ON(sparsemap_buf);

Why do we need a BUG_ON() here?
Looking at the code I cannot really see how we can end up with sparsemap_buf being NULL.
Is it just for over-protection?

> +	sparsemap_buf =
> +		memblock_virt_alloc_try_nid_raw(size, PAGE_SIZE,
> +						__pa(MAX_DMA_ADDRESS),
> +						BOOTMEM_ALLOC_ACCESSIBLE, nid);

In your previous version, you didn't pass a required alignment when setting up sparsemap_buf.
size is already PMD_SIZE aligned, do we need to align it also to PAGE_SIZE?

Thanks
-- 
Oscar Salvador
SUSE L3
