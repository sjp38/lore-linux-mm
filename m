Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4D46B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 02:07:08 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so5646776wmu.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 23:07:08 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id z6si24820397wmg.146.2016.08.23.23.07.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 23:07:07 -0700 (PDT)
Date: Wed, 24 Aug 2016 07:06:57 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] io-mapping: Fixup for different names of writecombine
Message-ID: <20160824060657.GA13362@nuc-i3427.alporthouse.com>
References: <20160823202233.4681-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823202233.4681-1-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>

On Tue, Aug 23, 2016 at 10:22:33PM +0200, Daniel Vetter wrote:
> Somehow architectures can't agree on this. And for good measure make
> sure we have a fallback which should work everywhere (fingers
> crossed).
> 
> This is to fix a compile fail on microblaze in gpiolib-of.c, which
> misguidedly includes io-mapping.h (instead of screaming at whichever
> achitecture doesn't correctly pull in asm/io.h from linux/io.h).
> 
> Not tested since there's no reasonable way to get at microblaze
> toolchains :(
> 
> Fixes: ac96b5566926 ("io-mapping.h: s/PAGE_KERNEL_IO/PAGE_KERNEL/")
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>

As mentioned I'm looking at reducing the number of unused includes of
io-mapping.h, discussion in progress over at gpio/mlx4.

On the positive side, this does at least mean the WC pgprot mess is
hidden away in the header!

Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
