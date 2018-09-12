Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D56A98E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:44:32 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h5-v6so4369978itb.3
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:44:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w64-v6sor923984itd.11.2018.09.12.09.44.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 09:44:31 -0700 (PDT)
MIME-Version: 1.0
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234354.4068.65260.stgit@localhost.localdomain> <7b96298e-9590-befd-0670-ed0c9fcf53d5@microsoft.com>
 <CAKgT0UdKZVUPBk=rg5kfUuFBpuZQEKPuGw31x5O2nMyuULgi0g@mail.gmail.com> <4d520227-52d3-6cd0-11d8-9be534097ea5@microsoft.com>
In-Reply-To: <4d520227-52d3-6cd0-11d8-9be534097ea5@microsoft.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 12 Sep 2018 09:44:19 -0700
Message-ID: <CAKgT0Uf7Wo3JdrMub-NFv3RXJx6+vT4MVXzyQwh1v+JMbK2VgA@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel.Tatashin@microsoft.com
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm@lists.01.org, Michal Hocko <mhocko@suse.com>, dave.jiang@intel.com, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, jglisse@redhat.com, Andrew Morton <akpm@linux-foundation.org>, logang@deltatee.com, dan.j.williams@intel.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Sep 12, 2018 at 8:54 AM Pasha Tatashin
<Pavel.Tatashin@microsoft.com> wrote:
>
>
>
> On 9/12/18 11:48 AM, Alexander Duyck wrote:
> > On Wed, Sep 12, 2018 at 6:59 AM Pasha Tatashin
> > <Pavel.Tatashin@microsoft.com> wrote:
> >>
> >> Hi Alex,
> >
> > Hi Pavel,
> >
> >> Please re-base on linux-next,  memmap_init_zone() has been updated there
> >> compared to mainline. You might even find a way to unify some parts of
> >> memmap_init_zone and memmap_init_zone_device as memmap_init_zone() is a
> >> lot simpler now.
> >
> > This patch applied to the linux-next tree with only a little bit of
> > fuzz. It looks like it is mostly due to some code you had added above
> > the function as well. I have updated this patch so that it will apply
> > to both linux and linux-next by just moving the new function to
> > underneath memmap_init_zone instead of above it.
> >
> >> I think __init_single_page() should stay local to page_alloc.c to keep
> >> the inlining optimization.
> >
> > I agree. In addition it will make pulling common init together into
> > one space easier. I would rather not have us create an opportunity for
> > things to further diverge by making it available for anybody to use.
> >
> >> I will review you this patch once you send an updated version.
> >
> > Other than moving the new function from being added above versus below
> > there isn't much else that needs to change, at least for this patch. I
> > have some follow-up patches I am planning that will be targeted for
> > linux-next. Those I think will focus more on what you have in mind in
> > terms of combining this new function
>
> Hi Alex,
>
> I'd like see the combining to be part of the same series. May be this
> patch can be pulled from this series and merged with your upcoming
> patches series?
>
> Thank you,
> Pavel

The problem is the issue is somewhat time sensitive, and the patches I
put out in this set needed to be easily backported. That is one of the
reasons this patch set is as conservative as it is.

I was hoping to make 4.20 with this patch set at the latest. My
follow-up patches are more of what I would consider 4.21 material as
it will be something we will probably want to give some testing time,
and I figure there will end up being a few revisions. I would probably
have them ready for review in another week or so.

Thanks.

- Alex
