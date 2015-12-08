Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C09A56B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 07:07:43 -0500 (EST)
Received: by pfbg73 with SMTP id g73so11688515pfb.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 04:07:43 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id qz6si4908860pab.168.2015.12.08.04.07.42
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 04:07:42 -0800 (PST)
Date: Tue, 8 Dec 2015 12:07:44 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 01/13] mm/memblock: add MEMBLOCK_NOMAP attribute to
 memblock memory table
Message-ID: <20151208120743.GG19612@arm.com>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
 <1448886507-3216-2-git-send-email-ard.biesheuvel@linaro.org>
 <CAKv+Gu9oboT_Lk8heJWRcM=oxRW=EWioVCvZLH7N0YCkfU5tJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu9oboT_Lk8heJWRcM=oxRW=EWioVCvZLH7N0YCkfU5tJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ryan Harkin <ryan.harkin@linaro.org>, Grant Likely <grant.likely@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Leif Lindholm <leif.lindholm@linaro.org>

Hi Ard,

On Thu, Dec 03, 2015 at 11:55:53AM +0100, Ard Biesheuvel wrote:
> On 30 November 2015 at 13:28, Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> > This introduces the MEMBLOCK_NOMAP attribute and the required plumbing
> > to make it usable as an indicator that some parts of normal memory
> > should not be covered by the kernel direct mapping. It is up to the
> > arch to actually honor the attribute when laying out this mapping,
> > but the memblock code itself is modified to disregard these regions
> > for allocations and other general use.
> >
> > Cc: linux-mm@kvack.org
> > Cc: Alexander Kuleshov <kuleshovmail@gmail.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
> > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > ---
> >  include/linux/memblock.h |  8 ++++++
> >  mm/memblock.c            | 28 ++++++++++++++++++++
> >  2 files changed, 36 insertions(+)

[...]

> May I kindly ask team-mm/Andrew/Alexander to chime in here, and
> indicate whether you are ok with this patch going in for 4.5? If so,
> could you please provide your ack so the patch can be kept together
> with the rest of the series, which depends on it?

I'm keen to queue this in the arm64 tree, since it's a prerequisite for
cleaning up a bunch of our EFI code and sharing it with 32-bit ARM.

> I should note that this change should not affect any memblock users
> that never set the MEMBLOCK_NOMAP flag, but please, if you see any
> issues beyond 'this may conflict with other stuff we have queued for
> 4.5', please do let me know.

Indeed, I can't see that this would cause any issues, but I would really
like an Ack from one of the MM maintainers before taking this.

Please could somebody take a look?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
