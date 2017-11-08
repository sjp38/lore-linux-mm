Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C71B440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:04:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i67so2324614pfi.23
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:04:49 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h13si3932092pgs.399.2017.11.08.07.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 07:04:48 -0800 (PST)
Date: Wed, 8 Nov 2017 07:04:47 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] vmalloc: introduce vmap_pfn for persistent memory
Message-ID: <20171108150447.GA10374@infradead.org>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108095909.GA7390@infradead.org>
 <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, dm-devel@redhat.com, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@lst.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 08, 2017 at 07:33:09AM -0500, Mikulas Patocka wrote:
> We could use the function clwb() (or arch-independent wrapper dax_flush()) 
> - that uses the clflushopt instruction on Broadwell or clwb on Skylake - 
> but it is very slow, write performance on Broadwell is only 350MB/s.
> 
> So in practice I use the movnti instruction that bypasses cache. The 
> write-combining buffer is flushed with sfence.

And what do you do for an architecture with virtuall indexed caches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
