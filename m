Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02D8E6B026B
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 20:41:51 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id c41so5607798otc.18
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:41:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g124sor2809076oif.56.2017.12.15.17.41.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 17:41:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215140947.26075-3-hch@lst.de>
References: <20171215140947.26075-1-hch@lst.de> <20171215140947.26075-3-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 17:41:49 -0800
Message-ID: <CAPcyv4jduU6jZgfGWzirj2oj5-7g_mArriNGBhueaQzmUOLL6Q@mail.gmail.com>
Subject: Re: [PATCH 02/17] mm: don't export arch_add_memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, X86 ML <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 15, 2017 at 6:09 AM, Christoph Hellwig <hch@lst.de> wrote:
> Only x86_64 and sh export this symbol, and it is not used by any
> modular code.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks good,

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
