Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD0DC6B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 13:51:57 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id w78so6156759oiw.6
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 10:51:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s12sor3903404oie.107.2017.12.17.10.51.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 10:51:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-17-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-17-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 17 Dec 2017 10:51:56 -0800
Message-ID: <CAPcyv4ixo=A949dN4c=LVc6x+Bdk67ERSO8xR5FQwHnL9mxQAw@mail.gmail.com>
Subject: Re: [PATCH 16/17] memremap: change devm_memremap_pages interface to
 use struct dev_pagemap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> From: Logan Gunthorpe <logang@deltatee.com>
>
> This new interface is similar to how struct device (and many others)
> work. The caller initializes a 'struct dev_pagemap' as required
> and calls 'devm_memremap_pages'. This allows the pagemap structure to
> be embedded in another structure and thus container_of can be used. In
> this way application specific members can be stored in a containing
> struct.
>
> This will be used by the P2P infrastructure and HMM could probably
> be cleaned up to use it as well (instead of having it's own, similar
> 'hmm_devmem_pages_create' function).
>
> Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good, I notice that this does not initialize pgmap->type to
MEMORY_DEVICE_HOST, but since that value is zero and likely won't
change we're ok.

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
