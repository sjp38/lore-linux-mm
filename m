Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3E316B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 18:22:55 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h7-v6so216180lfc.13
        for <linux-mm@kvack.org>; Tue, 29 May 2018 15:22:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t184-v6sor4307189lfe.38.2018.05.29.15.22.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 15:22:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
References: <152694211402.5484.2277538346144115181.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180524001026.GA3527@redhat.com> <CAPcyv4hVERZoqWrCxwOkmM075OP_ada7FiYsQgokijuWyC1MbA@mail.gmail.com>
From: Dave Airlie <airlied@gmail.com>
Date: Wed, 30 May 2018 08:22:53 +1000
Message-ID: <CAPM=9tzMJq=KC+ijoj-JGmc1R3wbshdwtfR3Zpmyaw3jYJ9+gw@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm: rework hmm to use devm_memremap_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 24 May 2018 at 13:18, Dan Williams <dan.j.williams@intel.com> wrote:
> On Wed, May 23, 2018 at 5:10 PM, Jerome Glisse <jglisse@redhat.com> wrote:
>> On Mon, May 21, 2018 at 03:35:14PM -0700, Dan Williams wrote:
>>> Hi Andrew, please consider this series for 4.18.
>>>
>>> For maintainability, as ZONE_DEVICE continues to attract new users,
>>> it is useful to keep all users consolidated on devm_memremap_pages() as
>>> the interface for create "device pages".
>>>
>>> The devm_memremap_pages() implementation was recently reworked to make
>>> it more generic for arbitrary users, like the proposed peer-to-peer
>>> PCI-E enabling. HMM pre-dated this rework and opted to duplicate
>>> devm_memremap_pages() as hmm_devmem_pages_create().
>>>
>>> Rework HMM to be a consumer of devm_memremap_pages() directly and fix up
>>> the licensing on the exports given the deep dependencies on the mm.
>>
>> I am on PTO right now so i won't be able to quickly review it all
>> but forcing GPL export is problematic for me now. I rather have
>> device driver using "sane" common helpers than creating their own
>> crazy thing.
>
> Sane drivers that need this level of deep integration with Linux
> memory management need to be upstream. Otherwise, HMM is an
> unprecedented departure from the norms of Linux kernel development.

Isn't it the author of code choice what EXPORT_SYMBOL to use? and
isn't the agreement that if something is EXPORT_SYMBOL now, changing
underlying exports isn't considered a good idea. We've seen this before
with the refcount fun,

See d557d1b58b3546bab2c5bc2d624c5709840e6b10

Not commenting on the legality or what derived works are considered,
since really the markings are just an indication of the authors opinion,
and at this stage I think are actually meaningless, since we've diverged
considerably from the advice given to Linus back when this started.

If Christoph is willing to enforce it the markings won't matter either way.

Dave.
