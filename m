Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 811816B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:02:44 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id o16so1321459wmf.4
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:02:44 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id h197si1482185wma.256.2017.12.19.07.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 07:02:43 -0800 (PST)
Date: Tue, 19 Dec 2017 16:02:42 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 06/17] mm: pass the vmem_altmap to arch_remove_memory
	and __remove_pages
Message-ID: <20171219150242.GA13124@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-7-hch@lst.de> <CAPcyv4iNDonroVQy7YFsM-uC_0GMsjQgSBj=ZfdOB-XUK5tsKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4iNDonroVQy7YFsM-uC_0GMsjQgSBj=ZfdOB-XUK5tsKw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 06:04:37PM -0800, Dan Williams wrote:
> On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> > We can just pass this on instead of having to do a radix tree lookup
> > without proper locking 2 levels into the callchain.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>wip
> 
> I assume that "wip" is a typo?

It was the description of the patch this got folded into in my
local tree.  So basically equivalent to a typo :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
