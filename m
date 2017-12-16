Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF6AA6B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:24:25 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id p4so5691166oti.15
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 18:24:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q24sor3261365ote.321.2017.12.15.18.24.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 18:24:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-11-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-11-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 18:24:24 -0800
Message-ID: <CAPcyv4gu=Q4bW+hOJFbeWr7t6T8CyiOSYCcNRYCy3HnokBFd=w@mail.gmail.com>
Subject: Re: [PATCH 10/17] mm: merge vmem_altmap_alloc into altmap_alloc_block_buf
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> There is no clear separation between the two, so merge them.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
