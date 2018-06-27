Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54BD66B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 19:39:42 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id t20-v6so3758736qkj.15
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 16:39:42 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e185-v6si1503926qkb.291.2018.06.27.16.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 16:39:41 -0700 (PDT)
Date: Thu, 28 Jun 2018 07:39:36 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v5 0/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
Message-ID: <20180627233936.GE8970@localhost.localdomain>
References: <20180627013116.12411-1-bhe@redhat.com>
 <CAGM2reYKn80fn8Nb_AT4ybVih4c7cd8+U1nDfJ-C0fwM+DB4jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reYKn80fn8Nb_AT4ybVih4c7cd8+U1nDfJ-C0fwM+DB4jw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

Hi Pavel,

On 06/27/18 at 01:47pm, Pavel Tatashin wrote:
> This work made me think why do we even have
> CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER ? This really should be the
> default behavior for all systems. Yet, it is enabled only on x86_64.
> We could clean up an already messy sparse.c if we removed this config,
> and enabled its path for all arches. We would not break anything
> because if we cannot allocate one large mmap_map we still fallback to
> allocating a page at a time the same as what happens when
> CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=n.

Thanks for your idea.

Seems the common ARCHes all have ARCH_SPARSEMEM_ENABLE, such as x86,
arm/64, power, s390, mips, others don't have. For them, removing
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER makes sense. 

I will make a clean up patch to do this, but I can only test it on x86.
If test robot or other issues report issue on this clean up patch,
Andrew can help only pick the current 4 patches after updating, then
we can continue discussing the clean up patch. From the current code, it
should be OK to all ARCHes.

Thanks
Baoquan
