Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AD4832808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 07:55:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id t12so23172237pgo.7
        for <linux-mm@kvack.org>; Wed, 10 May 2017 04:55:09 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m4si2857136pfg.120.2017.05.10.04.55.08
        for <linux-mm@kvack.org>;
        Wed, 10 May 2017 04:55:08 -0700 (PDT)
Date: Wed, 10 May 2017 12:55:12 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3 3/3] arm64: Silence first allocation with
 CONFIG_ARM64_MODULE_PLTS=y
Message-ID: <20170510115511.GB15307@arm.com>
References: <20170427181902.28829-1-f.fainelli@gmail.com>
 <20170427181902.28829-4-f.fainelli@gmail.com>
 <20170503111814.GF8233@arm.com>
 <3af577ca-8f01-7a1c-997c-4c04914b4633@gmail.com>
 <20170508100723.GF8526@arm.com>
 <20170510083803.ur44myyb35lqcuw7@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510083803.ur44myyb35lqcuw7@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, Michal Hocko <mhocko@suse.com>, open list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Russell King <linux@armlinux.org.uk>, Chris Wilson <chris@chris-wilson.co.uk>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, zijun_hu <zijun_hu@htc.com>, angus@angusclark.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

On Wed, May 10, 2017 at 09:38:03AM +0100, Catalin Marinas wrote:
> On Mon, May 08, 2017 at 11:07:24AM +0100, Will Deacon wrote:
> > On Fri, May 05, 2017 at 02:07:28PM -0700, Florian Fainelli wrote:
> > > On 05/03/2017 04:18 AM, Will Deacon wrote:
> > > > On Thu, Apr 27, 2017 at 11:19:02AM -0700, Florian Fainelli wrote:
> > > >> When CONFIG_ARM64_MODULE_PLTS is enabled, the first allocation using the
> > > >> module space fails, because the module is too big, and then the module
> > > >> allocation is attempted from vmalloc space. Silence the first allocation
> > > >> failure in that case by setting __GFP_NOWARN.
> > > >>
> > > >> Reviewed-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > > >> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> > > >> ---
> > > >>  arch/arm64/kernel/module.c | 7 ++++++-
> > > >>  1 file changed, 6 insertions(+), 1 deletion(-)
> > > > 
> > > > I'm not sure what the merge plan is for these, but the arm64 bit here
> > > > looks fine to me:
> > > > 
> > > > Acked-by: Will Deacon <will.deacon@arm.com>
> > > 
> > > Thanks, not sure either, would you or Catalin want to pick this series?
> > 
> > We'd need an Ack from Russell on the arch/arm/ part before we could take
> > this series.
> 
> The first patch touches mm/vmalloc.c, so we could also merge the series
> via akpm's tree. Andrew, do you have any preference?

Michal Hocko acked that one, so I think we can take the whole series via
arm64.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
