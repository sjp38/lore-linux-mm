Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 4985C6B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 10:17:03 -0400 (EDT)
Date: Thu, 5 Jul 2012 15:17:00 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
Message-ID: <20120705141700.GI3399@mudshark.cambridge.arm.com>
References: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
 <CAJd=RBAmF3dtb8wtEbS-A7BNT=RLsb5emQQWVU8ioeQOO8D7NA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBAmF3dtb8wtEbS-A7BNT=RLsb5emQQWVU8ioeQOO8D7NA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Jul 05, 2012 at 01:37:46PM +0100, Hillf Danton wrote:
> On Wed, Jul 4, 2012 at 10:32 PM, Will Deacon <will.deacon@arm.com> wrote:
> > When allocating and returning clear huge pages to userspace as a
> > response to a fault, we may zero and return a mapping to a previously
> > dirtied physical region (for example, it may have been written by
> > a private mapping which was freed as a result of an ftruncate on the
> > backing file). On architectures with Harvard caches, this can lead to
> > I/D inconsistency since the zeroed view may not be visible to the
> > instruction stream.
> >
> > This patch solves the problem by flushing the region after allocating
> > and clearing a new huge page. Note that PowerPC avoids this issue by
> > performing the flushing in their clear_user_page implementation to keep
> > the loader happy, however this is closely tied to the semantics of the
> > PG_arch_1 page flag which is architecture-specific.
> >
> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> > ---
> 
> Thanks:)
> 
> Acked-by: Hillf Danton <dhillf@gmail.com>

Thanks Hillf. Which tree does this stuff usually go through?

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
