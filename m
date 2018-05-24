Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EBB6D6B0005
	for <linux-mm@kvack.org>; Thu, 24 May 2018 02:29:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e26-v6so493956wmh.7
        for <linux-mm@kvack.org>; Wed, 23 May 2018 23:29:38 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k184-v6si2824279wmk.47.2018.05.23.23.29.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 23:29:37 -0700 (PDT)
Date: Thu, 24 May 2018 08:35:07 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Message-ID: <20180524063507.GA9750@lst.de>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com> <20180524001026.GA3527@redhat.com> <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, May 23, 2018 at 08:18:11PM -0700, Dan Williams wrote:
> On Wed, May 23, 2018 at 5:10 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> > On Mon, May 21, 2018 at 03:35:14PM -0700, Dan Williams wrote:
> >> Hi Andrew, please consider this series for 4.18.
> >>
> >> For maintainability, as ZONE_DEVICE continues to attract new users,
> >> it is useful to keep all users consolidated on devm_memremap_pages() as
> >> the interface for create "device pages".
> >>
> >> The devm_memremap_pages() implementation was recently reworked to make
> >> it more generic for arbitrary users, like the proposed peer-to-peer
> >> PCI-E enabling. HMM pre-dated this rework and opted to duplicate
> >> devm_memremap_pages() as hmm_devmem_pages_create().
> >>
> >> Rework HMM to be a consumer of devm_memremap_pages() directly and fix up
> >> the licensing on the exports given the deep dependencies on the mm.
> >
> > I am on PTO right now so i won't be able to quickly review it all
> > but forcing GPL export is problematic for me now. I rather have
> > device driver using "sane" common helpers than creating their own
> > crazy thing.
> 
> Sane drivers that need this level of deep integration with Linux
> memory management need to be upstream. Otherwise, HMM is an
> unprecedented departure from the norms of Linux kernel development.

Agreed.  I consider every driver using this a derived work, independ
on the marking or not.  And I'm willing to enforce this.
