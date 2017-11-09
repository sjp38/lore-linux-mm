Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93CC36B0339
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 11:40:31 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id b189so4822280oia.10
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 08:40:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x41si3861175otd.78.2017.11.09.08.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 08:40:30 -0800 (PST)
Date: Thu, 9 Nov 2017 11:40:24 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH] vmalloc: introduce vmap_pfn for persistent
 memory
In-Reply-To: <CAPcyv4imHXhcd8WgW5ygrKKNiVr0cDZLi2Ue5WDy=_RmqECnvw@mail.gmail.com>
Message-ID: <alpine.LRH.2.02.1711091138450.9079@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com> <20171108095909.GA7390@infradead.org> <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com> <20171108150447.GA10374@infradead.org>
 <alpine.LRH.2.02.1711081007570.8618@file01.intranet.prod.int.rdu2.redhat.com> <20171108153522.GB24548@infradead.org> <CAPcyv4jw5CDJYo-uhxq1hWJo90R87m0qju-k8WKgyd34QKnz0Q@mail.gmail.com> <alpine.LRH.2.02.1711081514320.29922@file01.intranet.prod.int.rdu2.redhat.com>
 <CAPcyv4imHXhcd8WgW5ygrKKNiVr0cDZLi2Ue5WDy=_RmqECnvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, dm-devel@redhat.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Laura Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>



On Wed, 8 Nov 2017, Dan Williams wrote:

> On Wed, Nov 8, 2017 at 12:15 PM, Mikulas Patocka <mpatocka@redhat.com> wrote:
> >
> >
> > On Wed, 8 Nov 2017, Dan Williams wrote:
> >
> >> On Wed, Nov 8, 2017 at 7:35 AM, Christoph Hellwig <hch@infradead.org> wrote:
> >> > On Wed, Nov 08, 2017 at 10:21:38AM -0500, Mikulas Patocka wrote:
> >> >> > And what do you do for an architecture with virtuall indexed caches?
> >> >>
> >> >> Persistent memory is not supported on such architectures - it is only
> >> >> supported on x86-64 and arm64.
> >> >
> >> > For now.  But once support is added your driver will just corrupt data
> >> > unless you have the right API in place.
> >>
> >> I'm also in the process of ripping out page-less dax support. With
> >> pages we can potentially leverage the VIVT-cache support in some
> >> architectures, likely with more supporting infrastructure for
> >> dax_flush().
> >
> > Should I remove all the code for page-less persistent memory from my
> > driver?
> >
> 
> Yes, that would be my recommendation. You can see that filesystem-dax
> is on its way to dropping page-less support in this series:
> 
>    https://lists.01.org/pipermail/linux-nvdimm/2017-October/013125.html

Why do you indend to drop dax for ramdisk? It's perfect for testing.

On x86, persistent memory can be tested with the memmap kernel parameters, 
but on other architectures, ramdisk is the only option for tests.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
