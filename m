Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBD48E0002
	for <linux-mm@kvack.org>; Sat, 12 Jan 2019 11:50:54 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id 124so9189399ybb.9
        for <linux-mm@kvack.org>; Sat, 12 Jan 2019 08:50:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x74sor14676916ywx.165.2019.01.12.08.50.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 12 Jan 2019 08:50:53 -0800 (PST)
MIME-Version: 1.0
References: <1547288798-10243-1-git-send-email-anshuman.khandual@arm.com>
 <20190112121230.GQ6310@bombadil.infradead.org> <ddd59fdc-3d8f-4015-e851-e7f099193a1b@c-s.fr>
 <20190112154944.GT6310@bombadil.infradead.org>
In-Reply-To: <20190112154944.GT6310@bombadil.infradead.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 12 Jan 2019 08:50:42 -0800
Message-ID: <CALvZod5XfFujzzMC0n2dZmofjof0juWw45RF4475CAEu9nAv3Q@mail.gmail.com>
Subject: Re: [PATCH] mm: Introduce GFP_PGTABLE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>, Anshuman Khandual <anshuman.khandual@arm.com>, mark.rutland@arm.com, Michal Hocko <mhocko@suse.com>, linux-sh@vger.kernel.org, peterz@infradead.org, catalin.marinas@arm.com, Dave Hansen <dave.hansen@linux.intel.com>, will.deacon@arm.com, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, marc.zyngier@arm.com, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, steve.capper@arm.com, christoffer.dall@arm.com, james.morse@arm.com, aneesh.kumar@linux.ibm.com, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On Sat, Jan 12, 2019 at 7:50 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Sat, Jan 12, 2019 at 02:49:29PM +0100, Christophe Leroy wrote:
> > As far as I can see,
> >
> > #define GFP_KERNEL_ACCOUNT (GFP_KERNEL | __GFP_ACCOUNT)
> >
> > So what's the difference between:
> >
> > (GFP_KERNEL_ACCOUNT | __GFP_ZERO) & ~__GFP_ACCOUNT
> >
> > and
> >
> > (GFP_KERNEL | __GFP_ZERO) & ~__GFP_ACCOUNT
>
> Nothing.  But there's a huge difference in the other parts of that same
> file where GFP_ACCOUNT is _not_ used.
>
> I think this unification is too small to bother with.  Something I've
> had on my todo list for some time and have not done anything about
> is to actually unify all of the architecture pte/pmd/... allocations.
> There are tricks some architectures use that others would benefit from.

Can you explain a bit more on this? If this is too low priority on
your todo list then maybe me or someone else can pick that up.

Shakeel
