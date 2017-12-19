Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 995806B025F
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:03:49 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id t92so11549626wrc.13
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:03:49 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d18si1587727wme.183.2017.12.19.07.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 07:03:48 -0800 (PST)
Date: Tue, 19 Dec 2017 16:03:47 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 16/17] memremap: change devm_memremap_pages interface
	to use struct dev_pagemap
Message-ID: <20171219150347.GC13124@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-17-hch@lst.de> <CAPcyv4ixo=A949dN4c=LVc6x+Bdk67ERSO8xR5FQwHnL9mxQAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ixo=A949dN4c=LVc6x+Bdk67ERSO8xR5FQwHnL9mxQAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Dec 17, 2017 at 10:51:56AM -0800, Dan Williams wrote:
> On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> > From: Logan Gunthorpe <logang@deltatee.com>
> >
> > This new interface is similar to how struct device (and many others)
> > work. The caller initializes a 'struct dev_pagemap' as required
> > and calls 'devm_memremap_pages'. This allows the pagemap structure to
> > be embedded in another structure and thus container_of can be used. In
> > this way application specific members can be stored in a containing
> > struct.
> >
> > This will be used by the P2P infrastructure and HMM could probably
> > be cleaned up to use it as well (instead of having it's own, similar
> > 'hmm_devmem_pages_create' function).
> >
> > Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Looks good, I notice that this does not initialize pgmap->type to
> MEMORY_DEVICE_HOST, but since that value is zero and likely won't
> change we're ok.

I'll add it jut for clarity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
