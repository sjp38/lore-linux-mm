Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 156F46B025E
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 13:19:45 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b132so45383604iti.5
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 10:19:45 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id dw4si19373425pac.33.2016.11.14.10.19.44
        for <linux-mm@kvack.org>;
        Mon, 14 Nov 2016 10:19:44 -0800 (PST)
Date: Mon, 14 Nov 2016 18:19:38 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCHv2 5/6] arm64: Use __pa_symbol for _end
Message-ID: <20161114181937.GG3096@e104818-lin.cambridge.arm.com>
References: <20161102210054.16621-1-labbott@redhat.com>
 <20161102210054.16621-6-labbott@redhat.com>
 <20161102225241.GA19591@remoulade>
 <3724ea58-3c04-1248-8359-e2927da03aaf@redhat.com>
 <20161103155106.GF25852@remoulade>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161103155106.GF25852@remoulade>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, x86@kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Thu, Nov 03, 2016 at 03:51:07PM +0000, Mark Rutland wrote:
> On Wed, Nov 02, 2016 at 05:56:42PM -0600, Laura Abbott wrote:
> > On 11/02/2016 04:52 PM, Mark Rutland wrote:
> > >On Wed, Nov 02, 2016 at 03:00:53PM -0600, Laura Abbott wrote:
> > >>
> > >>__pa_symbol is technically the marco that should be used for kernel
> > >>symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL.
> > >
> > >Nit: s/marco/macro/
> > >
> > >I see there are some other uses of __pa() that look like they could/should be
> > >__pa_symbol(), e.g. in mark_rodata_ro().
> > >
> > >I guess strictly speaking those need to be updated to? Or is there a reason
> > >that we should not?
> > 
> > If the concept of __pa_symbol is okay then yes I think all uses of __pa
> > should eventually be converted for consistency and debugging.
> 
> I have no strong feelings either way about __pa_symbol(); I'm not clear on what
> the purpose of __pa_symbol() is specifically, but I'm happy even if it's just
> for consistency with other architectures.

At a quick grep, it seems to only be used by mips and x86 and a single
place in mm/memblock.c.

Since we haven't seen any issues on arm/arm64 without this macro, can we
not just continue to use __pa()?

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
