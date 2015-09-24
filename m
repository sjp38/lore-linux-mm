Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3918982F66
	for <linux-mm@kvack.org>; Thu, 24 Sep 2015 11:10:04 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so75616416pac.0
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 08:10:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id oc9si19021498pbb.111.2015.09.24.08.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Sep 2015 08:10:03 -0700 (PDT)
Date: Thu, 24 Sep 2015 08:10:02 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/15] avr32: convert to asm-generic/memory_model.h
Message-ID: <20150924151002.GA24375@infradead.org>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
 <20150923044118.36490.75919.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150923044118.36490.75919.stgit@dwillia2-desk3.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@ml01.01.org

On Wed, Sep 23, 2015 at 12:41:18AM -0400, Dan Williams wrote:
> Switch avr32/include/asm/page.h to use the common defintions for
> pfn_to_page(), page_to_pfn(), and ARCH_PFN_OFFSET.

This was the last architecture not using asm-generic/memory_model.h,
so it might be time to move it to linux/ or even fold it into an
existing header.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
