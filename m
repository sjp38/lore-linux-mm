Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A5D6E6B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 05:30:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m19so24424918pgd.14
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 02:30:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l1si564010pld.70.2017.06.09.02.30.33
        for <linux-mm@kvack.org>;
        Fri, 09 Jun 2017 02:30:34 -0700 (PDT)
Date: Fri, 9 Jun 2017 10:29:48 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v5] mm: huge-vmap: fail gracefully on unexpected huge
 vmap mappings
Message-ID: <20170609092947.GB10665@leverpostej>
References: <20170609082226.26152-1-ard.biesheuvel@linaro.org>
 <20170609092209.GA10665@leverpostej>
 <CAKv+Gu_te54d9VU9AKYevkOvSpCBBeDQy5PE+PhX-t=ka3L8JA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu_te54d9VU9AKYevkOvSpCBBeDQy5PE+PhX-t=ka3L8JA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Zhong Jiang <zhongjiang@huawei.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, Jun 09, 2017 at 09:27:15AM +0000, Ard Biesheuvel wrote:
> On 9 June 2017 at 09:22, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Fri, Jun 09, 2017 at 08:22:26AM +0000, Ard Biesheuvel wrote:
> >> v4: - use pud_bad/pmd_bad instead of pud_huge/pmd_huge, which don't require
> >>       changes to hugetlb.h, and give us what we need on all architectures
> >>     - move WARN_ON_ONCE() calls out of conditionals
> 
> ^^^

Ah, sorry. Clearly I scanned this too quickly.

> >> +     WARN_ON_ONCE(pud_bad(*pud));
> >> +     if (pud_none(*pud) || pud_bad(*pud))
> >>               return NULL;
> >
> > Nit: the WARN_ON_ONCE() can be folded into the conditional:
> >
> >         if (pud_none(*pud) || WARN_ON_ONCE(pud_bad(*pud)))
> >                 reutrn NULL;

> Actually, it was Dave who requested them to be taken out of the conditional.

Fair enough. My ack stands, either way!

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
