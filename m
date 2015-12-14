Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id EF07E6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 09:52:37 -0500 (EST)
Received: by qgew101 with SMTP id w101so48299143qge.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 06:52:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g201si3897920qhc.132.2015.12.14.06.52.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 06:52:36 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [-mm PATCH v2 00/25] get_user_pages() for dax pte and pmd mappings
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
	<x49r3iutbv2.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4gfMSW=x=LcZeEqX6hvO39Q2=nyUxq3FwMxaZ6PEGZtMg@mail.gmail.com>
	<x49fuzat8k9.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4jtF2LwK3jbsjPHB7=JE1O0-TkRQGQcMSrB9bPZVdFd8A@mail.gmail.com>
Date: Mon, 14 Dec 2015 09:52:27 -0500
In-Reply-To: <CAPcyv4jtF2LwK3jbsjPHB7=JE1O0-TkRQGQcMSrB9bPZVdFd8A@mail.gmail.com>
	(Dan Williams's message of "Thu, 10 Dec 2015 18:03:31 -0800")
Message-ID: <x49lh8xccb8.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Toshi Kani <toshi.kani@hpe.com>, David Airlie <airlied@linux.ie>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Christoph Hellwig <hch@lst.de>, Andrea Arcangeli <aarcange@redhat.com>, kbuild test robot <lkp@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Richard Weinberger <richard@nod.at>, X86 ML <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Christoffer Dall <christoffer.dall@linaro.org>, Jan Kara <jack@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dan Williams <dan.j.williams@intel.com> writes:

> In the meantime, I expect some would say DAX is a toy as long as it
> continues to fail at DMA.

I suppose this is the crux of it.  Given that we may be able to migrate
away from the allocation of storage for temporary data structures in the
future, and given that admin tooling could hide the undesirable
configurations, this approach seems workable.

Thanks,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
