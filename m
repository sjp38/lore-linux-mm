Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D25526B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:26:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x2-v6so7832296wmc.3
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:26:43 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h34-v6si13911702wrf.259.2018.05.21.23.26.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 23:26:42 -0700 (PDT)
Date: Tue, 22 May 2018 08:31:56 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 4/5] mm, hmm: replace hmm_devmem_pages_create() with
	devm_memremap_pages()
Message-ID: <20180522063156.GD7925@lst.de>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com> <152694213486.5484.5340142369038375338.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152694213486.5484.5340142369038375338.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 21, 2018 at 03:35:34PM -0700, Dan Williams wrote:
> Commit e8d513483300 "memremap: change devm_memremap_pages interface to
> use struct dev_pagemap" refactored devm_memremap_pages() to allow a
> dev_pagemap instance to be supplied. Passing in a dev_pagemap interface
> simplifies the design of pgmap type drivers in that they can rely on
> container_of() to lookup any private data associated with the given
> dev_pagemap instance.
> 
> In addition to the cleanups this also gives hmm users multi-order-radix
> improvements that arrived with commit ab1b597ee0e4 "mm,
> devm_memremap_pages: use multi-order radix for ZONE_DEVICE lookups"

None of them has any caller despite being in the tree for 9 month.
I think it's time to simply drop the whole hmm code instead instead of
carrying this dead weight around.
