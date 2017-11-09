Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52D1D440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 13:58:45 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id b189so5075880oia.10
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 10:58:45 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e44sor774564otd.331.2017.11.09.10.58.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 10:58:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1711091340140.5328@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108095909.GA7390@infradead.org> <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108150447.GA10374@infradead.org> <alpine.LRH.2.02.1711081007570.8618@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108153522.GB24548@infradead.org> <alpine.LRH.2.02.1711081236570.1168@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108174747.GA12199@infradead.org> <alpine.LRH.2.02.1711081516010.29922@file01.intranet.prod.int.rdu2.redhat.com>
 <CAPcyv4hR7DQ98ZCqqeyD2ihO0jWpQqPv_+s4v6iVaiNWrv96vw@mail.gmail.com>
 <alpine.LRH.2.02.1711091130070.9079@file01.intranet.prod.int.rdu2.redhat.com>
 <CAPcyv4jb4UW_qjzenyKCbbufSL0rHGBU4OHDQo9BH212Kjtppg@mail.gmail.com>
 <alpine.LRH.2.02.1711091231240.28067@file01.intranet.prod.int.rdu2.redhat.com>
 <CAPcyv4jsUuROY9Bk8xXupuJq22xRUDoiiTSqegv-njUR6MxeYw@mail.gmail.com> <alpine.LRH.2.02.1711091340140.5328@file01.intranet.prod.int.rdu2.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 9 Nov 2017 10:58:43 -0800
Message-ID: <CAPcyv4j6K13wjn+BQJ-_S1iuuxuU6_XsfhwKRc9ZkxxGH9xc-Q@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH] vmalloc: introduce vmap_pfn for persistent memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, dm-devel@redhat.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Laura Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "Luck, Tony" <tony.luck@intel.com>

On Thu, Nov 9, 2017 at 10:51 AM, Mikulas Patocka <mpatocka@redhat.com> wrote:
[..]
>> The drivers don't need to react, once the pages are pinned for dma the
>> hot-unplug will not progress until all those page references are
>> dropped.
>
> I am not talking about moving pages here, I'm talking about possible
> hardware errors in persistent memory. In this situation, the storage
> controller receives an error on the bus - and the question is, how will it
> react. Ideally, it should abort just this transfer and return an error
> that the driver will propagate up. But I'm skeptical that someone is
> really testing the controllers and drivers for this possiblity.

This is something that drive controllers already need to deal with
today on DRAM, but I suspect you are right because in general
error-path testing in drivers is rare to non-existent in Linux. We can
endeavor to do better with persistent memory where we have some
explicit error injection facilities defined in ACPI that might enjoy
wider support than the existing EINJ facility.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
