Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84DFC6B0268
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:15:44 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id q67so4898250oig.14
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 18:15:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y16sor2817605oia.312.2017.12.15.18.15.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 18:15:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-9-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-9-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 18:15:43 -0800
Message-ID: <CAPcyv4i6MvJ5X8potRT2nwFDXAGHNGEooxw_vV_h2+sHoRnUSg@mail.gmail.com>
Subject: Re: [PATCH 08/17] mm: pass the vmem_altmap to memmap_init_zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> Pass the vmem_altmap two levels down instead of needing a lookup.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Given the fact that HMM and now P2P are attracted to
devm_memremap_pages() I think this churn is worth it. vmem_altmap is
worth being considered a first class citizen of memory hotplug and not
a hidden hack.

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
