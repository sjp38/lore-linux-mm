Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id AB8706B0007
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 18:42:46 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m15-v6so761764ioj.13
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 15:42:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2-v6sor601202iog.55.2018.06.12.15.42.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 15:42:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180612071621.26775-1-npiggin@gmail.com> <20180612071621.26775-4-npiggin@gmail.com>
 <CA+55aFzKBieD0Y3sgFQzt+x5esqb9vT6SEQ28xyCz5UWegfFVg@mail.gmail.com> <20180613083131.139a3c34@roar.ozlabs.ibm.com>
In-Reply-To: <20180613083131.139a3c34@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 12 Jun 2018 15:42:34 -0700
Message-ID: <CA+55aFyk9VBLUk8VYhfEUR55x0TXY9_QX1dE4wE0A_ias9tMNQ@mail.gmail.com>
Subject: Re: [RFC PATCH 3/3] powerpc/64s/radix: optimise TLB flush with
 precise TLB ranges in mmu_gather
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-arch <linux-arch@vger.kernel.org>, "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 12, 2018 at 3:31 PM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> Okay sure, and this is the reason for the wide cc list. Intel does
> need it of course, from 4.10.3.1 of the dev manual:
>
>   =E2=80=94 The processor may create a PML4-cache entry even if there are=
 no
>     translations for any linear address that might use that entry
>     (e.g., because the P flags are 0 in all entries in the referenced
>     page-directory-pointer table).

But does intel need it?

Because I don't see it. We already do the __tlb_adjust_range(), and we
never tear down the highest-level page tables afaik.

Am I missing something?

               Linus
