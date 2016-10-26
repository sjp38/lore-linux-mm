Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB36E6B0276
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 09:39:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f78so29233128oih.7
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 06:39:07 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id x9si1491768otx.18.2016.10.26.06.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 06:39:06 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id a195so1612576oib.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 06:39:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a5418089-2615-8c04-aca8-50ceb43978f1@mellanox.com>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com> <a5418089-2615-8c04-aca8-50ceb43978f1@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 26 Oct 2016 06:39:05 -0700
Message-ID: <CAPcyv4h9Ubgiv1B8FPqes-zUXMckzfEi6uqtfc4GrLc_8BeSLg@mail.gmail.com>
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: Stephen Bates <sbates@raithlin.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>

On Wed, Oct 26, 2016 at 1:24 AM, Haggai Eran <haggaie@mellanox.com> wrote:
[..]
>> I wonder if we could (ab)use a
>> software-defined 'pasid' as the requester id for a peer-to-peer
>> mapping that needs address translation.
> Why would you need that? Isn't it enough to map the peer-to-peer
> addresses correctly in the iommu driver?
>

You're right, we might already have enough...

We would just need to audit iommu drivers to undo any assumptions that
the page being mapped is always in host memory and apply any bus
address translations between source device and target device.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
