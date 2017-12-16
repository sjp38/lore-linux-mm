Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C54B6B0268
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 20:41:33 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v137so4825882oia.21
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:41:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r12sor2907130otr.260.2017.12.15.17.41.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 17:41:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-2-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-2-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 17:41:31 -0800
Message-ID: <CAPcyv4iENTTRvoigbdtztrtKiAFbBuCcwYwQ+c02XuCRGToH6g@mail.gmail.com>
Subject: Re: [PATCH 01/17] memremap: provide stubs for vmem_altmap_offset and vmem_altmap_free
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> Currently all calls to those functions are eliminated by the compiler when
> CONFIG_ZONE_DEVICE is not set, but this soon won't be the case.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
