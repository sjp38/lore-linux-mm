Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E01E26B026A
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 04:49:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so17519593pgq.7
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:49:32 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m1si32895565pfa.104.2016.11.23.01.49.31
        for <linux-mm@kvack.org>;
        Wed, 23 Nov 2016 01:49:32 -0800 (PST)
Date: Wed, 23 Nov 2016 09:48:47 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv3 5/6] arm64: Use __pa_symbol for kernel symbols
Message-ID: <20161123094847.GC24624@leverpostej>
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
 <1479431816-5028-6-git-send-email-labbott@redhat.com>
 <20161118143543.GC1197@leverpostej>
 <92635df6-9a58-02cf-3230-1a84c28370d1@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <92635df6-9a58-02cf-3230-1a84c28370d1@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: lorenzo.pieralisi@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Mon, Nov 21, 2016 at 09:40:06AM -0800, Laura Abbott wrote:
> On 11/18/2016 06:35 AM, Mark Rutland wrote:
> > On Thu, Nov 17, 2016 at 05:16:55PM -0800, Laura Abbott wrote:
> >>  	/* Grab the vDSO code pages. */
> >>  	for (i = 0; i < vdso_pages; i++)
> >> -		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa(&vdso_start)) + i);
> >> +		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa_symbol(&vdso_start)) + i);
> > 
> > Nit: phys_to_page() again.
> 
> I think it makes sense to keep this one as is. It's offsetting
> by pfn number and trying force phys_to_page would make it more
> difficult to read.

My bad; I failed to spot the + i.

That sounds good to me; sorry for the noise there.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
