Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id ACED16B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:05:24 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k135so95664259lfb.2
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 05:05:24 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id x17si20694752wma.104.2016.08.23.05.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 05:05:22 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id i138so17798026wmf.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 05:05:22 -0700 (PDT)
Date: Tue, 23 Aug 2016 14:05:18 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH] io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/
Message-ID: <20160823120518.GE10980@phenom.ffwll.local>
References: <20160823072253.26977-1-chris@chris-wilson.co.uk>
 <1471939443.3696.2.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1471939443.3696.2.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, Daniel Vetter <daniel.vetter@ffwll.ch>, linux-mm@kvack.org

On Tue, Aug 23, 2016 at 11:04:03AM +0300, Joonas Lahtinen wrote:
> On ti, 2016-08-23 at 08:22 +0100, Chris Wilson wrote:
> > PAGE_KERNEL_IO is an x86-ism. Though it is used to define the pgprot_t
> > used for the iomapped region, it itself is just PAGE_KERNEL. On all
> > other arches, PAGE_KERNEL_IO is undefined so in a general header we must
> > refrain from using it.
> > 
> 
> There is;
> 
> #define __PAGE_KERNEL_IOA A A A A A A A A A A (__PAGE_KERNEL)
> 
> So no functional change, but will compile on all archs.
> 
> Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

Still not happy:

  CC      drivers/gpio/gpiolib-of.o
In file included from drivers/gpio/gpiolib-of.c:19:0:
./include/linux/io-mapping.h: In function a??io_mapping_init_wca??:
./include/linux/io-mapping.h:125:16: error: implicit declaration of function a??pgprot_writecombinea?? [-Werror=implicit-function-declaration]
  iomap->prot = pgprot_writecombine(PAGE_KERNEL);
                ^~~~~~~~~~~~~~~~~~~
./include/linux/io-mapping.h:125:36: error: a??PAGE_KERNELa?? undeclared (first use in this function)
  iomap->prot = pgprot_writecombine(PAGE_KERNEL);
                                    ^~~~~~~~~~~
./include/linux/io-mapping.h:125:36: note: each undeclared identifier is reported only once for each function it appears in
cc1: some warnings being treated as errors
scripts/Makefile.build:289: recipe for target 'drivers/gpio/gpiolib-of.o' failed
make[2]: *** [drivers/gpio/gpiolib-of.o] Error 1
scripts/Makefile.build:440: recipe for target 'drivers/gpio' failed
make[1]: *** [drivers/gpio] Error 2
make[1]: *** Waiting for unfinished jobs....
  DTC     drivers/gpu/drm/tilcdc/tilcdc_slave_compat.dtb
  DTB     drivers/gpu/drm/tilcdc/tilcdc_slave_compat.dtb.S
  AS      drivers/gpu/drm/tilcdc/tilcdc_slave_compat.dtb.o
  LD      drivers/gpu/drm/tilcdc/built-in.o
rm drivers/gpu/drm/tilcdc/tilcdc_slave_compat.dtb drivers/gpu/drm/tilcdc/tilcdc_slave_compat.dtb.S
  LD      drivers/gpu/drm/built-in.o
  LD      drivers/gpu/built-in.o
Makefile:968: recipe for target 'drivers' failed
make: *** [drivers] Error 2

arm compile-testing howto:

http://blog.ffwll.ch/2016/02/arm-kernel-cross-compiling.html

Thanks, Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
