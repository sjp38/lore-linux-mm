Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id C801D6B0038
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 20:36:38 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so41319717wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 17:36:38 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id lf10si7749006wjc.47.2015.09.25.17.36.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 17:36:37 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so38539564wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 17:36:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150924151002.GA24375@infradead.org>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
	<20150923044118.36490.75919.stgit@dwillia2-desk3.jf.intel.com>
	<20150924151002.GA24375@infradead.org>
Date: Fri, 25 Sep 2015 17:36:36 -0700
Message-ID: <CAPcyv4h_UrwTM7QiNMzxC3uV7bLOMKC4cNqwbikyj6w4AiKjWA@mail.gmail.com>
Subject: Re: [PATCH 01/15] avr32: convert to asm-generic/memory_model.h
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Tony Luck <tony.luck@intel.com>

On Thu, Sep 24, 2015 at 8:10 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Sep 23, 2015 at 12:41:18AM -0400, Dan Williams wrote:
>> Switch avr32/include/asm/page.h to use the common defintions for
>> pfn_to_page(), page_to_pfn(), and ARCH_PFN_OFFSET.
>
> This was the last architecture not using asm-generic/memory_model.h,
> so it might be time to move it to linux/ or even fold it into an
> existing header.

I went to go attempt this, but ia64 is still a holdout, as its
DISCONTIGMEM setup can't use the generic memory_model definitions.

#ifdef CONFIG_DISCONTIGMEM
# define page_to_pfn(page)      ((unsigned long) (page - vmem_map))
# define pfn_to_page(pfn)       (vmem_map + (pfn))
#else
# include <asm-generic/memory_model.h>
#endif
#else
# include <asm-generic/memory_model.h>
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
