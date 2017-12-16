Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id A731F6B026C
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 20:42:11 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id c58so5606373otd.17
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:42:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x192sor2489616oix.29.2017.12.15.17.42.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 17:42:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-4-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-4-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 17:42:10 -0800
Message-ID: <CAPcyv4iuLNA4JSm7S1dg=7baxMPTPhKa=9HMJB=iwycz20mfCw@mail.gmail.com>
Subject: Re: [PATCH 03/17] mm: don't export __add_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> This function isn't used by any modules, and is only to be called
> from core MM code.  This includes the calls for the add_pages wrapper
> that might be inlined.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
