Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9896B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 02:27:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y82-v6so7827312wmb.5
        for <linux-mm@kvack.org>; Mon, 21 May 2018 23:27:23 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id w1-v6si4626785wrk.170.2018.05.21.23.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 23:27:22 -0700 (PDT)
Date: Tue, 22 May 2018 08:32:36 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 5/5] mm, hmm: mark hmm_devmem_{add, add_resource}
	EXPORT_SYMBOL_GPL
Message-ID: <20180522063236.GE7925@lst.de>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com> <152694214044.5484.1081005408496303826.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152694214044.5484.1081005408496303826.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 21, 2018 at 03:35:40PM -0700, Dan Williams wrote:
> The routines hmm_devmem_add(), and hmm_devmem_add_resource() are small
> wrappers around devm_memremap_pages(). The devm_memremap_pages()
> interface is a subset of the hmm functionality which has more and deeper
> ties into the kernel memory management implementation. It was an
> oversight that these symbols were not marked EXPORT_SYMBOL_GPL from the
> outset due to how they originally copied (and now reuse)
> devm_memremap_pages().

If we end up keeping this code: absolutely.  Then again I think without
an actual user this should have never been merged, and should be removed
until one shows up.

Reviewed-by: Christoph Hellwig <hch@lst.de>
