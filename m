Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0991F6B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 21:18:07 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id f13so4901987oib.20
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 18:18:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c76sor2779782oib.75.2017.12.15.18.18.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 18:18:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-10-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-10-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 18:18:05 -0800
Message-ID: <CAPcyv4g0074zD9ztrMu3cT-sVpZfkCK=i6F0XohRxw5TKDupVA@mail.gmail.com>
Subject: Re: [PATCH 09/17] mm: split altmap memory map allocation from normal case
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> No functional changes, just untangling the call chain.

I'd also mention that creating more helper functions in the altmap_
namespace helps document why altmap is passed all around the hotplug
code.

>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
