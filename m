Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4E366B03BB
	for <linux-mm@kvack.org>; Mon,  8 May 2017 06:07:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d127so65966557pga.11
        for <linux-mm@kvack.org>; Mon, 08 May 2017 03:07:22 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u26si8757939pgo.283.2017.05.08.03.07.21
        for <linux-mm@kvack.org>;
        Mon, 08 May 2017 03:07:21 -0700 (PDT)
Date: Mon, 8 May 2017 11:07:24 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3 3/3] arm64: Silence first allocation with
 CONFIG_ARM64_MODULE_PLTS=y
Message-ID: <20170508100723.GF8526@arm.com>
References: <20170427181902.28829-1-f.fainelli@gmail.com>
 <20170427181902.28829-4-f.fainelli@gmail.com>
 <20170503111814.GF8233@arm.com>
 <3af577ca-8f01-7a1c-997c-4c04914b4633@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3af577ca-8f01-7a1c-997c-4c04914b4633@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On Fri, May 05, 2017 at 02:07:28PM -0700, Florian Fainelli wrote:
> On 05/03/2017 04:18 AM, Will Deacon wrote:
> > On Thu, Apr 27, 2017 at 11:19:02AM -0700, Florian Fainelli wrote:
> >> When CONFIG_ARM64_MODULE_PLTS is enabled, the first allocation using the
> >> module space fails, because the module is too big, and then the module
> >> allocation is attempted from vmalloc space. Silence the first allocation
> >> failure in that case by setting __GFP_NOWARN.
> >>
> >> Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> >> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> >> ---
> >>  arch/arm64/kernel/module.c | 7 ++++++-
> >>  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > I'm not sure what the merge plan is for these, but the arm64 bit here
> > looks fine to me:
> > 
> > Acked-by: Will Deacon <will.deacon@arm.com>
> 
> Thanks, not sure either, would you or Catalin want to pick this series?

We'd need an Ack from Russell on the arch/arm/ part before we could take
this series.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
