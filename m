Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6536B0289
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 11:51:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 83so13056342pfx.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 08:51:11 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e4si8550808pag.332.2016.11.03.08.51.10
        for <linux-mm@kvack.org>;
        Thu, 03 Nov 2016 08:51:10 -0700 (PDT)
Date: Thu, 3 Nov 2016 15:51:07 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv2 5/6] arm64: Use __pa_symbol for _end
Message-ID: <20161103155106.GF25852@remoulade>
References: <20161102210054.16621-1-labbott@redhat.com>
 <20161102210054.16621-6-labbott@redhat.com>
 <20161102225241.GA19591@remoulade>
 <3724ea58-3c04-1248-8359-e2927da03aaf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3724ea58-3c04-1248-8359-e2927da03aaf@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Wed, Nov 02, 2016 at 05:56:42PM -0600, Laura Abbott wrote:
> On 11/02/2016 04:52 PM, Mark Rutland wrote:
> >On Wed, Nov 02, 2016 at 03:00:53PM -0600, Laura Abbott wrote:
> >>
> >>__pa_symbol is technically the marco that should be used for kernel
> >>symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL.
> >
> >Nit: s/marco/macro/
> >
> >I see there are some other uses of __pa() that look like they could/should be
> >__pa_symbol(), e.g. in mark_rodata_ro().
> >
> >I guess strictly speaking those need to be updated to? Or is there a reason
> >that we should not?
> 
> If the concept of __pa_symbol is okay then yes I think all uses of __pa
> should eventually be converted for consistency and debugging.

I have no strong feelings either way about __pa_symbol(); I'm not clear on what
the purpose of __pa_symbol() is specifically, but I'm happy even if it's just
for consistency with other architectures.

However, if we use it I think that we should (attempt to) use it consistently
from the outset. 

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
