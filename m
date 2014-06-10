Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE796B00DA
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 22:45:23 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so169589pad.3
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 19:45:22 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ro12si1169272pab.172.2014.06.09.19.45.21
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 19:45:22 -0700 (PDT)
Date: Tue, 10 Jun 2014 11:49:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] DMA, CMA: use general CMA reserved area
 management framework
Message-ID: <20140610024910.GB19036@js1304-P5Q-DELUXE>
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1401757919-30018-3-git-send-email-iamjoonsoo.kim@lge.com>
 <xa1twqcyjx3z.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xa1twqcyjx3z.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jun 03, 2014 at 09:00:48AM +0200, Michal Nazarewicz wrote:
> On Tue, Jun 03 2014, Joonsoo Kim wrote:
> > Now, we have general CMA reserved area management framework,
> > so use it for future maintainabilty. There is no functional change.
> >
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> > diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
> > index dfb1dc9..ecb85ac 100644
> > --- a/include/linux/dma-contiguous.h
> > +++ b/include/linux/dma-contiguous.h
> > @@ -53,9 +53,10 @@
> >  
> >  #ifdef __KERNEL__
> >  
> > +#include <linux/device.h>
> > +
> 
> Why is this suddenly required?
> 
> >  struct cma;
> >  struct page;
> > -struct device;
> >  
> >  #ifdef CONFIG_DMA_CMA
> 

Without including device.h, build failure occurs.
In dma-contiguous.h, we try to access to dev->cma_area, so we need
device.h. In the past, we included it luckily by swap.h in
drivers/base/dma-contiguous.c. Swap.h includes node.h and then node.h
includes device.h, so we were happy. But, in this patch, I remove
'include <linux/swap.h>' so we need to include device.h explicitly.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
