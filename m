Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1126B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 13:53:52 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id m43so4075272otb.7
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 10:53:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s5sor3947301oia.134.2017.12.17.10.53.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 10:53:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-18-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-18-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 17 Dec 2017 10:53:50 -0800
Message-ID: <CAPcyv4g2sBf2V6=nKtuqOOS50L1rJu_xZ+x_5=rEzS4JDJfHAw@mail.gmail.com>
Subject: Re: [PATCH 17/17] memremap: merge find_dev_pagemap into get_dev_pagemap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> There is only one caller of the trivial function find_dev_pagemap left,
> so just merge it into the caller.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

...and all of these pass the nvdimm unit tests, so I think we're good
to go. I'll rebase the filesystem-DAX vs DMA collision series on top
of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
