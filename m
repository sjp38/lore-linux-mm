Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 461A06B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 09:14:56 -0500 (EST)
Received: by padfa1 with SMTP id fa1so24307305pad.9
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 06:14:56 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id cj15si1350101pdb.1.2015.03.03.06.14.55
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 06:14:55 -0800 (PST)
Date: Tue, 3 Mar 2015 14:14:49 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH 3/4] arm64: add support for memtest
Message-ID: <20150303141449.GM28951@e104818-lin.cambridge.arm.com>
References: <1425308145-20769-1-git-send-email-vladimir.murzin@arm.com>
 <1425308145-20769-4-git-send-email-vladimir.murzin@arm.com>
 <20150302185607.GG7919@arm.com>
 <54F57E62.6050206@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F57E62.6050206@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Mark Rutland <Mark.Rutland@arm.com>, "lauraa@codeaurora.org" <lauraa@codeaurora.org>, "arnd@arndb.de" <arnd@arndb.de>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, "tglx@linutronix.de" <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Mar 03, 2015 at 09:26:58AM +0000, Vladimir Murzin wrote:
> On 02/03/15 18:56, Will Deacon wrote:
> > On Mon, Mar 02, 2015 at 02:55:44PM +0000, Vladimir Murzin wrote:
> >> Add support for memtest command line option.
> >>
> >> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
> >> ---
> >>  arch/arm64/mm/init.c |    2 ++
> >>  1 file changed, 2 insertions(+)
> >>
> >> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> >> index ae85da6..597831b 100644
> >> --- a/arch/arm64/mm/init.c
> >> +++ b/arch/arm64/mm/init.c
> >> @@ -190,6 +190,8 @@ void __init bootmem_init(void)
> >>  	min = PFN_UP(memblock_start_of_DRAM());
> >>  	max = PFN_DOWN(memblock_end_of_DRAM());
> >>  
> >> +	early_memtest(min << PAGE_SHIFT, max << PAGE_SHIFT);
> >> +
> >>  	/*
> >>  	 * Sparsemem tries to allocate bootmem in memory_present(), so must be
> >>  	 * done after the fixed reservations.
> > 
> > This is really neat, thanks for doing this Vladimir!
> > 
> >   Acked-by: Will Deacon <will.deacon@arm.com>
> > 
> > For the series, modulo Baruch's comments about Documentation updates.
> 
> Thanks Will! I'll wait for awhile for other comments and repost updated
> version.
> 
> I wonder which tree it might go?

Since it touches mm, x86, arm, arm64, I guess it could go in via the mm
tree (akpm). We could take it via the arm64 tree as well if we have all
the acks in place.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
