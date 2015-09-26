Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2B63D6B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 16:10:29 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so139136352pac.2
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 13:10:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id yk2si14843314pac.192.2015.09.26.13.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 13:10:28 -0700 (PDT)
Date: Sat, 26 Sep 2015 13:10:27 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/15] avr32: convert to asm-generic/memory_model.h
Message-ID: <20150926201027.GB27728@infradead.org>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044118.36490.75919.stgit@dwillia2-desk3.jf.intel.com>
 <20150924151002.GA24375@infradead.org>
 <CAPcyv4h_UrwTM7QiNMzxC3uV7bLOMKC4cNqwbikyj6w4AiKjWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4h_UrwTM7QiNMzxC3uV7bLOMKC4cNqwbikyj6w4AiKjWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Tony Luck <tony.luck@intel.com>

On Fri, Sep 25, 2015 at 05:36:36PM -0700, Dan Williams wrote:
> I went to go attempt this, but ia64 is still a holdout, as its
> DISCONTIGMEM setup can't use the generic memory_model definitions.
> 
> #ifdef CONFIG_DISCONTIGMEM
> # define page_to_pfn(page)      ((unsigned long) (page - vmem_map))
> # define pfn_to_page(pfn)       (vmem_map + (pfn))
> #else
> # include <asm-generic/memory_model.h>
> #endif
> #else
> # include <asm-generic/memory_model.h>
> #endif

Seems like we should simply introduce a CONFIG_VMEM_MAP for ia64
to get this started.  Does my memory trick me or did we used to have
vmem_map on other architectures as well but managed to get rid of it
everywhere but on ia64?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
