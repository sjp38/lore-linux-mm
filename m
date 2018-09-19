Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0588E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 21:24:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o16-v6so1653856pgv.21
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 18:24:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z3-v6sor1916145pgi.217.2018.09.18.18.24.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 18:24:20 -0700 (PDT)
Date: Wed, 19 Sep 2018 11:24:15 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v5 6/7] mm, hmm: Replace hmm_devmem_pages_create() with
 devm_memremap_pages()
Message-ID: <20180919012415.GE8537@350D>
References: <153680531988.453305.8080706591516037706.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153680535314.453305.11205770267271657025.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <153680535314.453305.11205770267271657025.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, alexander.h.duyck@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 12, 2018 at 07:22:33PM -0700, Dan Williams wrote:
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
> 
> As part of the conversion to the devm_memremap_pages() method of
> handling the percpu_ref relative to when pages are put, the percpu_ref
> completion needs to move to hmm_devmem_ref_exit(). See commit
> 71389703839e ("mm, zone_device: Replace {get, put}_zone_device_page...")
> for details.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Cc: "Jerome Glisse" <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---

Looks like a good cleanup

Acked-by: Balbir Singh <bsingharora@gmail.com>
