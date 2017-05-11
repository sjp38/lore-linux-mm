Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D31066B02C4
	for <linux-mm@kvack.org>; Thu, 11 May 2017 09:53:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e131so20225311pfh.7
        for <linux-mm@kvack.org>; Thu, 11 May 2017 06:53:19 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a1si205375pld.147.2017.05.11.06.53.17
        for <linux-mm@kvack.org>;
        Thu, 11 May 2017 06:53:17 -0700 (PDT)
Date: Thu, 11 May 2017 14:53:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 3/3] arm64: Silence first allocation with
 CONFIG_ARM64_MODULE_PLTS=y
Message-ID: <20170511135310.GA28576@e104818-lin.cambridge.arm.com>
References: <20170427181902.28829-1-f.fainelli@gmail.com>
 <20170427181902.28829-4-f.fainelli@gmail.com>
 <20170503111814.GF8233@arm.com>
 <3af577ca-8f01-7a1c-997c-4c04914b4633@gmail.com>
 <20170508100723.GF8526@arm.com>
 <20170510083803.ur44myyb35lqcuw7@localhost>
 <20170510115511.GB15307@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510115511.GB15307@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, Florian Fainelli <f.fainelli@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Russell King <linux@armlinux.org.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, angus@angusclark.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, May 10, 2017 at 12:55:12PM +0100, Will Deacon wrote:
> On Wed, May 10, 2017 at 09:38:03AM +0100, Catalin Marinas wrote:
> > On Mon, May 08, 2017 at 11:07:24AM +0100, Will Deacon wrote:
> > > On Fri, May 05, 2017 at 02:07:28PM -0700, Florian Fainelli wrote:
> > > > On 05/03/2017 04:18 AM, Will Deacon wrote:
> > > > > On Thu, Apr 27, 2017 at 11:19:02AM -0700, Florian Fainelli wrote:
> > > > >> When CONFIG_ARM64_MODULE_PLTS is enabled, the first allocation using the
> > > > >> module space fails, because the module is too big, and then the module
> > > > >> allocation is attempted from vmalloc space. Silence the first allocation
> > > > >> failure in that case by setting __GFP_NOWARN.
> > > > >>
> > > > >> Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > > > >> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> > > > >> ---
> > > > >>  arch/arm64/kernel/module.c | 7 ++++++-
> > > > >>  1 file changed, 6 insertions(+), 1 deletion(-)
> > > > > 
> > > > > I'm not sure what the merge plan is for these, but the arm64 bit here
> > > > > looks fine to me:
> > > > > 
> > > > > Acked-by: Will Deacon <will.deacon@arm.com>
> > > > 
> > > > Thanks, not sure either, would you or Catalin want to pick this series?
> > > 
> > > We'd need an Ack from Russell on the arch/arm/ part before we could take
> > > this series.
> > 
> > The first patch touches mm/vmalloc.c, so we could also merge the series
> > via akpm's tree. Andrew, do you have any preference?
> 
> Michal Hocko acked that one, so I think we can take the whole series via
> arm64.

OK. I'll send the patches for -rc1.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
