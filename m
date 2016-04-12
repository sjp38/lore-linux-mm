Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 00F016B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:00:44 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id zm5so15067465pac.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 08:00:43 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m22si10362840pfi.43.2016.04.12.08.00.42
        for <linux-mm@kvack.org>;
        Tue, 12 Apr 2016 08:00:42 -0700 (PDT)
Date: Tue, 12 Apr 2016 16:00:36 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/2] arm64: mm: make pfn always valid with flat memory
Message-ID: <20160412150036.GG8066@e104818-lin.cambridge.arm.com>
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <1459844572-53069-2-git-send-email-puck.chen@hisilicon.com>
 <570B85B6.8000805@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570B85B6.8000805@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Chen Feng <puck.chen@hisilicon.com>, mark.rutland@arm.com, dan.zhao@hisilicon.com, mhocko@suse.com, puck.chen@foxmail.com, ard.biesheuvel@linaro.org, suzhuangluan@hisilicon.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linuxarm@huawei.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, rientjes@google.com, oliver.fu@hisilicon.com, akpm@linux-foundation.org, robin.murphy@arm.com, yudongbin@hislicon.com, linux-arm-kernel@lists.infradead.org, saberlily.xia@hisilicon.com

On Mon, Apr 11, 2016 at 07:08:38PM +0800, Xishi Qiu wrote:
> On 2016/4/5 16:22, Chen Feng wrote:
> 
> > Make the pfn always valid when using flat memory.
> > If the reserved memory is not align to memblock-size,
> > there will be holes in zone.
> > 
> > This patch makes the memory in buddy always in the
> > array of mem-map.
> > 
> > Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
> > Signed-off-by: Fu Jun <oliver.fu@hisilicon.com>
> > ---
> >  arch/arm64/mm/init.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > index ea989d8..0e1d5b7 100644
> > --- a/arch/arm64/mm/init.c
> > +++ b/arch/arm64/mm/init.c
> > @@ -306,7 +306,8 @@ static void __init free_unused_memmap(void)
> 
> How about let free_unused_memmap() support for CONFIG_SPARSEMEM_VMEMMAP?

We would need extra care to check that the memmap was actually allocated
in the first place.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
