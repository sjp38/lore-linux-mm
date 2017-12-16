Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 81AEC6B026D
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:04:39 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id g98so5635987otg.11
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 18:04:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p11sor2798129otp.185.2017.12.15.18.04.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 18:04:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-7-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-7-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 18:04:37 -0800
Message-ID: <CAPcyv4iNDonroVQy7YFsM-uC_0GMsjQgSBj=ZfdOB-XUK5tsKw@mail.gmail.com>
Subject: Re: [PATCH 06/17] mm: pass the vmem_altmap to arch_remove_memory and __remove_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> We can just pass this on instead of having to do a radix tree lookup
> without proper locking 2 levels into the callchain.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>wip

I assume that "wip" is a typo?

Otherwise,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
