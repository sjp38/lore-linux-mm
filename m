Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 073C86B000A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 05:54:14 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id k5-v6so1280404ual.10
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 02:54:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 51-v6sor1418366uaj.153.2018.08.08.02.54.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 02:54:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <cbe2fb30-54b3-663e-4e30-448353723b8f@cybernetics.com>
References: <cbe2fb30-54b3-663e-4e30-448353723b8f@cybernetics.com>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Wed, 8 Aug 2018 12:54:12 +0300
Message-ID: <CAHp75Vcnf8m0zW+8Y8=fTE+F_bDjmaQpR0s2qiTdkOzqe2+fBA@mail.gmail.com>
Subject: Re: [PATCH v3 08/10] dmapool: improve accuracy of debug statistics
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>

On Tue, Aug 7, 2018 at 7:49 PM, Tony Battersby <tonyb@cybernetics.com> wrote:
> The "total number of blocks in pool" debug statistic currently does not
> take the boundary value into account, so it diverges from the "total
> number of blocks in use" statistic when a boundary is in effect.  Add a
> calculation for the number of blocks per allocation that takes the
> boundary into account, and use it to replace the inaccurate calculation.


> +       retval->blks_per_alloc =
> +               (allocation / boundary) * (boundary / size) +
> +               (allocation % boundary) / size;

If boundary is guaranteed to be power of 2, this can avoid cost
divisions (though it's a slow path anyway).

-- 
With Best Regards,
Andy Shevchenko
