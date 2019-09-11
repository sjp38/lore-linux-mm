Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01493C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:12:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB1EE2087E
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 15:12:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lephetGi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB1EE2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 451326B0275; Wed, 11 Sep 2019 11:12:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 402536B0276; Wed, 11 Sep 2019 11:12:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EFFC6B0277; Wed, 11 Sep 2019 11:12:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0039.hostedemail.com [216.40.44.39])
	by kanga.kvack.org (Postfix) with ESMTP id 099836B0275
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:12:17 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8A90D181AC9C6
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:12:16 +0000 (UTC)
X-FDA: 75922980672.11.river85_6b1675a4dda49
X-HE-Tag: river85_6b1675a4dda49
X-Filterd-Recvd-Size: 7303
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 15:12:15 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id h144so46550729iof.7
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:12:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hO/NYETIaCmxDsOv4YSewpLm6NfP264tWt7Tht5PRVc=;
        b=lephetGiRU0WJPYILZnpGeGY8fb67wSei8lpY0AzUmFYLYYZLCPr2QCdLVrZ3t9KqF
         VYRvj37vfpGu+yiAbV118YM/11MJeQt43ZHMr3XUooHwIgnEZAXkXmpwJZe97JfITjzm
         gMkhtrmUNbgtvpotn3Ps3YURVWTZw7d5jQoeB8ZqiFHPBQqOwktFsJKGPVQ2MvFqy7XC
         5wf7Cu3g32jyh6iKTGq2us71dxbfV5t0Qws2k9A6k0wStA2mODqcmOUdxF/R5Li9wADS
         PvwkDiEhtOuMIXiFo6eXN/M7r0UwnDWyHgSEi7TkB+U4O5S/iRH2R5EaQb7C+0VOL4OT
         CYnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=hO/NYETIaCmxDsOv4YSewpLm6NfP264tWt7Tht5PRVc=;
        b=EaeAaqe7gN9DolbbNl0o8I6XUvRYtI/TPJflpFPB2vaOfh+w2FupK4jJxlF+xWBY+u
         mdWZO56G9zeNj3jkEsXIkKJDGVjaTQgRq009xS+mL0hSfPR+BS9fUT0r3KnDG2IJlP+p
         S57sZCwwPX5q96l1RbJgFUdY5eGfpMwof19Y5IyveFfUk+WDKG0rBpOrHlNqgAfrY3Oq
         EDHiLefK26eOoH1qSEvEnI+uV6StwkzU8zkLe6v3cj92MnLSVOFKEBaAYXVqH5n5pOAA
         H5Ni5XBcfqhUpdLE0V7zP7k3+iAS3rzC7BlpY1TV8RY/AxISNU31t1Y+kvenJQiZ2sPX
         i80w==
X-Gm-Message-State: APjAAAWNJnagiP12pLLoxv2CqpXSaX1mxZds+Xv9hR0JZTlrPtr7EEnH
	94zPTWN+2LAmKJs32ce3ReBMzuwRy+VCvkyPiX0=
X-Google-Smtp-Source: APXvYqywFmqrX2zinHSJDKlW9JocoMGeJEpO0ksqi5JSiUqBmD89WL+vrXm3nKABzAcwsgWbhHFEtI94/Tj9EgUXE88=
X-Received: by 2002:a5d:8b47:: with SMTP id c7mr28072146iot.42.1568214734894;
 Wed, 11 Sep 2019 08:12:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190910124209.GY2063@dhcp22.suse.cz> <CAKgT0Udr6nYQFTRzxLbXk41SiJ-pcT_bmN1j1YR4deCwdTOaUQ@mail.gmail.com>
 <20190910144713.GF2063@dhcp22.suse.cz> <CAKgT0UdB4qp3vFGrYEs=FwSXKpBEQ7zo7DV55nJRO2C-KCEOrw@mail.gmail.com>
 <20190910175213.GD4023@dhcp22.suse.cz> <1d7de9f9f4074f67c567dbb4cc1497503d739e30.camel@linux.intel.com>
 <20190911113619.GP4023@dhcp22.suse.cz>
In-Reply-To: <20190911113619.GP4023@dhcp22.suse.cz>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 11 Sep 2019 08:12:03 -0700
Message-ID: <CAKgT0UfOp1c+ov=3pBD72EkSB9Vm7mG5G6zJj4=j=UH7zCgg2Q@mail.gmail.com>
Subject: Re: [PATCH v9 0/8] stg mail -e --version=v9 \
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, virtio-dev@lists.oasis-open.org, 
	kvm list <kvm@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, David Hildenbrand <david@redhat.com>, 
	Dave Hansen <dave.hansen@intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, will@kernel.org, 
	linux-arm-kernel@lists.infradead.org, Oscar Salvador <osalvador@suse.de>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Pankaj Gupta <pagupta@redhat.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitesh Narayan Lal <nitesh@redhat.com>, 
	Rik van Riel <riel@surriel.com>, lcapitulino@redhat.com, 
	"Wang, Wei W" <wei.w.wang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, 
	Paolo Bonzini <pbonzini@redhat.com>, Dan Williams <dan.j.williams@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 4:36 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 10-09-19 14:23:40, Alexander Duyck wrote:
> [...]
> > We don't put any limitations on the allocator other then that it needs to
> > clean up the metadata on allocation, and that it cannot allocate a page
> > that is in the process of being reported since we pulled it from the
> > free_list. If the page is a "Reported" page then it decrements the
> > reported_pages count for the free_area and makes sure the page doesn't
> > exist in the "Boundary" array pointer value, if it does it moves the
> > "Boundary" since it is pulling the page.
>
> This is still a non-trivial limitation on the page allocation from an
> external code IMHO. I cannot give any explicit reason why an ordering on
> the free list might matter (well except for page shuffling which uses it
> to make physical memory pattern allocation more random) but the
> architecture seems hacky and dubious to be honest. It shoulds like the
> whole interface has been developed around a very particular and single
> purpose optimization.

How is this any different then the code that moves a page that will
likely be merged to the tail though?

In our case the "Reported" page is likely going to be much more
expensive to allocate and use then a standard page because it will be
faulted back in. In such a case wouldn't it make sense for us to want
to keep the pages that don't require faults ahead of those pages in
the free_list so that they are more likely to be allocated? All we are
doing with the boundary list is preventing still resident pages from
being deferred behind pages that would require a page fault to get
access to.

> I remember that there was an attempt to report free memory that provided
> a callback mechanism [1], which was much less intrusive to the internals
> of the allocator yet it should provide a similar functionality. Did you
> see that approach? How does this compares to it? Or am I completely off
> when comparing them?
>
> [1] mostly likely not the latest version of the patchset
> http://lkml.kernel.org/r/1502940416-42944-5-git-send-email-wei.w.wang@intel.com

There have been a few comparisons between this patch set and the ones
from Wei Wang. In regards to the one you are pointing to the main
difference is that I am not permanently locking memory. Basically what
happens is that the iterator will take the lock, pull a few pages,
release the lock while reporting them, and then take the lock to
return those pages, grab some more, and repeat.

I was actually influenced somewhat by the suggestions that patchset
received, specifically I believe it resembles something like what was
suggested by Linus in response to v35 of that patch set:
https://lore.kernel.org/linux-mm/CA+55aFzqj8wxXnHAdUTiOomipgFONVbqKMjL_tfk7e5ar1FziQ@mail.gmail.com/

Basically where the feature Wei Wang was working on differs from this
patch set is that I need this to run continually, his only needed to
run periodically as he was just trying to identify free pages at a
fixed point in time. My goal is to identify pages that have been freed
since the last time I reported them. To do that I need a flag in the
page to identify those pages, and an iterator in the form of a
boundary pointer so that I can incrementally walk through the list
without losing track of freed pages.

