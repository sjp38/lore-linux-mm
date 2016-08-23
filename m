Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4086B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:21:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so84038619wme.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 05:21:25 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id m125si20827631wme.54.2016.08.23.05.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 05:21:24 -0700 (PDT)
Date: Tue, 23 Aug 2016 13:21:19 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/
Message-ID: <20160823122119.GK20834@nuc-i3427.alporthouse.com>
References: <20160823072253.26977-1-chris@chris-wilson.co.uk>
 <1471939443.3696.2.camel@linux.intel.com>
 <20160823120518.GE10980@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160823120518.GE10980@phenom.ffwll.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org

On Tue, Aug 23, 2016 at 02:05:18PM +0200, Daniel Vetter wrote:
> On Tue, Aug 23, 2016 at 11:04:03AM +0300, Joonas Lahtinen wrote:
> > On ti, 2016-08-23 at 08:22 +0100, Chris Wilson wrote:
> > > PAGE_KERNEL_IO is an x86-ism. Though it is used to define the pgprot_t
> > > used for the iomapped region, it itself is just PAGE_KERNEL. On all
> > > other arches, PAGE_KERNEL_IO is undefined so in a general header we must
> > > refrain from using it.
> > > 
> > 
> > There is;
> > 
> > #define __PAGE_KERNEL_IOA A A A A A A A A A A (__PAGE_KERNEL)
> > 
> > So no functional change, but will compile on all archs.
> > 
> > Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> 
> Still not happy:
> 
>   CC      drivers/gpio/gpiolib-of.o
> In file included from drivers/gpio/gpiolib-of.c:19:0:
> ./include/linux/io-mapping.h: In function a??io_mapping_init_wca??:
> ./include/linux/io-mapping.h:125:16: error: implicit declaration of function a??pgprot_writecombinea?? [-Werror=implicit-function-declaration]
>   iomap->prot = pgprot_writecombine(PAGE_KERNEL);
>                 ^~~~~~~~~~~~~~~~~~~
> ./include/linux/io-mapping.h:125:36: error: a??PAGE_KERNELa?? undeclared (first use in this function)
>   iomap->prot = pgprot_writecombine(PAGE_KERNEL);
>                                     ^~~~~~~~~~~

That was pulled in by the x86 headers,

#include <asm/pgtable.h>

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
