Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4269F6B0005
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 03:07:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 54-v6so2997861wrw.1
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 00:07:05 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n203-v6si2563979wmf.120.2018.06.06.00.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jun 2018 00:07:03 -0700 (PDT)
Date: Wed, 6 Jun 2018 09:14:18 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Message-ID: <20180606071418.GA7660@lst.de>
References: <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com> <CAPM=9tzMJq=KC+ijoj-JGmc1R3wbshdwtfR3Zpmyaw3jYJ9+gw@mail.gmail.com> <CAPcyv4g2XQtuYGPu8HMbPj6wXqGwxiL5jDRznf5fmW4WgC2DTw@mail.gmail.com> <CAPM=9twm=17t=2=M27ELB=vZWzpqM7GuwCUsC891jJ0t3JM4vg@mail.gmail.com> <CAPcyv4jTty4k1xXCOWbeRjzv-KjxNH1L4oOkWW1EbJt66jF4_w@mail.gmail.com> <20180605184811.GC4423@redhat.com> <CAPM=9twgL_tzkPO=V2mmecSzLjKJkEsJ8A4426fO2Nuus0N_UQ@mail.gmail.com> <CAPcyv4gSEYdnJKd=D-_yc3M=sY0HWjYzYhh5ha-v7KA4-40dsg@mail.gmail.com> <20180606000822.GE4423@redhat.com> <CAPcyv4gsS4xDXahZdOggURBHS2y-oJ5tPG9vXPDdY2p6jPufxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gsS4xDXahZdOggURBHS2y-oJ5tPG9vXPDdY2p6jPufxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Dave Airlie <airlied@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jun 05, 2018 at 06:33:04PM -0700, Dan Williams wrote:
> Unless the nouveau patches are using the entirety of what is already
> upstream for HMM, we should look to pare HMM back.
> 
> There is plenty of precedent of building a large capability
> out-of-tree and piecemeal merging it later, so I do not buy the
> "chicken-egg" argument. The change in the export is to make sure we
> don't repeat this backward "merge first, ask questions later" mistake
> in the future as devm_memremap_pages() is continuing to find new users
> like peer-to-peer DMA support and Linux is better off if that
> development is upstream. From a purely technical standpoint
> devm_memremap_pages() is EXPORT_SYMBOL_GPL because it hacks around
> several implementation details in the core kernel to achieve its goal,
> and it leaks new assumptions all over the kernel. It is strictly not a
> self contained interface.

Agreed with all of that.  And remember EXPORT_SYMBOL_GPL really just is
a clear expression of the authors they think these are internals.
The lack of it doesn't make it any less a derived work, we just remove
a very clear hint to users that they are poking very deeply into internals.

And with HMM they very clearly do.
