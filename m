Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC1BE6B0397
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 14:12:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v52so6014962wrb.14
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 11:12:27 -0700 (PDT)
Received: from mail-wr0-x229.google.com (mail-wr0-x229.google.com. [2a00:1450:400c:c0c::229])
        by mx.google.com with ESMTPS id t66si4427613wmg.38.2017.04.08.11.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Apr 2017 11:12:26 -0700 (PDT)
Received: by mail-wr0-x229.google.com with SMTP id g19so82346390wrb.0
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 11:12:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1491245884-15852-18-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com> <1491245884-15852-18-git-send-email-labbott@redhat.com>
From: Emil Velikov <emil.l.velikov@gmail.com>
Date: Sat, 8 Apr 2017 19:12:25 +0100
Message-ID: <CACvgo52qr=oBoiMnrww3cgoKozEMi3DwBV55c_GMi0mR_p0GcA@mail.gmail.com>
Subject: Re: [PATCHv3 17/22] staging: android: ion: Collapse internal header files
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, devel@driverdev.osuosl.org, Rom Lemarchand <romlem@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>, ML dri-devel <dri-devel@lists.freedesktop.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Daniel Vetter <daniel.vetter@intel.com>, LAKML <linux-arm-kernel@lists.infradead.org>, linux-media@vger.kernel.org

Hi Laura,

Couple of trivial nitpicks below.

On 3 April 2017 at 19:57, Laura Abbott <labbott@redhat.com> wrote:

> --- a/drivers/staging/android/ion/ion.h
> +++ b/drivers/staging/android/ion/ion.h
> @@ -1,5 +1,5 @@
>  /*
> - * drivers/staging/android/ion/ion.h
> + * drivers/staging/android/ion/ion_priv.h
Does not match the actual filename.

>   *
>   * Copyright (C) 2011 Google, Inc.
>   *
> @@ -14,24 +14,26 @@
>   *
>   */
>
> -#ifndef _LINUX_ION_H
> -#define _LINUX_ION_H
> +#ifndef _ION_PRIV_H
> +#define _ION_PRIV_H
>
Ditto.

> +#include <linux/device.h>
> +#include <linux/dma-direction.h>
> +#include <linux/kref.h>
> +#include <linux/mm_types.h>
> +#include <linux/mutex.h>
> +#include <linux/rbtree.h>
> +#include <linux/sched.h>
> +#include <linux/shrinker.h>
>  #include <linux/types.h>
> +#include <linux/miscdevice.h>
>
>  #include "../uapi/ion.h"
>
You don't want to use "../" in includes. Perhaps address with another
patch, if you haven't already ?

Regards,
Emil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
