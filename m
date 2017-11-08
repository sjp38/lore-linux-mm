Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD95440417
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 10:41:26 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id o126so2298287oif.21
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 07:41:26 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i58sor222283ote.70.2017.11.08.07.41.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 07:41:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171108153522.GB24548@infradead.org>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108095909.GA7390@infradead.org> <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108150447.GA10374@infradead.org> <alpine.LRH.2.02.1711081007570.8618@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108153522.GB24548@infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 8 Nov 2017 07:41:23 -0800
Message-ID: <CAPcyv4jw5CDJYo-uhxq1hWJo90R87m0qju-k8WKgyd34QKnz0Q@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH] vmalloc: introduce vmap_pfn for persistent memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, dm-devel@redhat.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Laura Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 8, 2017 at 7:35 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Nov 08, 2017 at 10:21:38AM -0500, Mikulas Patocka wrote:
>> > And what do you do for an architecture with virtuall indexed caches?
>>
>> Persistent memory is not supported on such architectures - it is only
>> supported on x86-64 and arm64.
>
> For now.  But once support is added your driver will just corrupt data
> unless you have the right API in place.

I'm also in the process of ripping out page-less dax support. With
pages we can potentially leverage the VIVT-cache support in some
architectures, likely with more supporting infrastructure for
dax_flush().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
