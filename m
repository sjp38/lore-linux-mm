Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1465E6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 14:14:23 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 8-v6so275888itz.4
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 11:14:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189-v6sor496796itm.49.2018.06.12.11.14.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 11:14:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180612071621.26775-1-npiggin@gmail.com> <20180612071621.26775-3-npiggin@gmail.com>
In-Reply-To: <20180612071621.26775-3-npiggin@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Jun 2018 11:14:10 -0700
Message-ID: <CA+55aFxaVyTZmKdywAGVopmWeDirb1Ou49XD_SfqGQL_ox_65Q@mail.gmail.com>
Subject: Re: [RFC PATCH 2/3] mm: mmu_gather track of invalidated TLB ranges
 explicitly for more precise flushing
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 12, 2018 at 12:16 AM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> +static inline void __tlb_adjust_page_range(struct mmu_gather *tlb,
> +                                     unsigned long address,
> +                                     unsigned int range_size)
> +{
> +       tlb->page_start = min(tlb->page_start, address);
> +       tlb->page_end = max(tlb->page_end, address + range_size);
> +}

Why add this unnecessary complexity for architectures where it doesn't matter?

This is not "generic". This is some crazy powerpc special case. Why
add it to generic code, and why make everybody else take the cost?

                    Linus
