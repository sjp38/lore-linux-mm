Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA8E6B000D
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 12:22:21 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u13-v6so3952518pfm.8
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 09:22:21 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p5-v6si4931544pgb.598.2018.08.03.09.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 Aug 2018 09:22:20 -0700 (PDT)
Date: Fri, 3 Aug 2018 09:22:12 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 2/9] dmapool: cleanup error messages
Message-ID: <20180803162212.GA4718@bombadil.infradead.org>
References: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
 <CAHp75Ve0su_S3ZWTtUEUohrs-iPiD1uzFOHhesLrWzJPOa2LNg@mail.gmail.com>
 <7a943124-c65e-f0ed-cc5c-20b23f021505@cybernetics.com>
 <b8547f8d-ac88-3d7b-9c2d-60a2f779259e@cybernetics.com>
 <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHp75VcoLVkp+BkFBLSqn95=3SaV-zr8cO1eSoQsrzZtJZESNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Tony Battersby <tonyb@cybernetics.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On Fri, Aug 03, 2018 at 06:59:20PM +0300, Andy Shevchenko wrote:
> >>> I'm pretty sure this was created in an order to avoid bad looking (and
> >>> in some cases frightening) "NULL device *" part.
> 
> JFYI: git log --no-merges --grep 'NULL device \*'

I think those commits actually argue in favour of Tony's patch to remove
the special casing.  Is it really useful to create dma pools with a NULL
device?
