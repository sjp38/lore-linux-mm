Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0B66B026D
	for <linux-mm@kvack.org>; Wed, 23 May 2018 23:18:14 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id n25-v6so143627otf.13
        for <linux-mm@kvack.org>; Wed, 23 May 2018 20:18:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18-v6sor10827095ote.155.2018.05.23.20.18.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 20:18:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180524001026.GA3527@redhat.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180524001026.GA3527@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 May 2018 20:18:11 -0700
Message-ID: <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable <stable@vger.kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, May 23, 2018 at 5:10 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Mon, May 21, 2018 at 03:35:14PM -0700, Dan Williams wrote:
>> Hi Andrew, please consider this series for 4.18.
>>
>> For maintainability, as ZONE_DEVICE continues to attract new users,
>> it is useful to keep all users consolidated on devm_memremap_pages() as
>> the interface for create "device pages".
>>
>> The devm_memremap_pages() implementation was recently reworked to make
>> it more generic for arbitrary users, like the proposed peer-to-peer
>> PCI-E enabling. HMM pre-dated this rework and opted to duplicate
>> devm_memremap_pages() as hmm_devmem_pages_create().
>>
>> Rework HMM to be a consumer of devm_memremap_pages() directly and fix up
>> the licensing on the exports given the deep dependencies on the mm.
>
> I am on PTO right now so i won't be able to quickly review it all
> but forcing GPL export is problematic for me now. I rather have
> device driver using "sane" common helpers than creating their own
> crazy thing.

Sane drivers that need this level of deep integration with Linux
memory management need to be upstream. Otherwise, HMM is an
unprecedented departure from the norms of Linux kernel development.
