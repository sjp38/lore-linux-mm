Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4CC2806E4
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 04:37:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z62so1716385wrc.0
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 01:37:01 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id q29si2453444wra.35.2017.04.19.01.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 01:37:00 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id z129so3623817wmb.1
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 01:37:00 -0700 (PDT)
Date: Wed, 19 Apr 2017 10:36:55 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Linaro-mm-sig] [PATCHv4 12/12] staging/android: Update Ion TODO
 list
Message-ID: <20170419083655.egqgf34dxdwpyomx@phenom.ffwll.local>
References: <1492540034-5466-1-git-send-email-labbott@redhat.com>
 <1492540034-5466-13-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1492540034-5466-13-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, romlem@google.com, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Daniel Vetter <daniel.vetter@intel.com>, Brian Starkey <brian.starkey@arm.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Tue, Apr 18, 2017 at 11:27:14AM -0700, Laura Abbott wrote:
> Most of the items have been taken care of by a clean up series. Remove
> the completed items and add a few new ones.
> 
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
>  drivers/staging/android/TODO | 21 ++++-----------------
>  1 file changed, 4 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/staging/android/TODO b/drivers/staging/android/TODO
> index 8f3ac37..5f14247 100644
> --- a/drivers/staging/android/TODO
> +++ b/drivers/staging/android/TODO
> @@ -7,23 +7,10 @@ TODO:
>  
>  
>  ion/
> - - Remove ION_IOC_SYNC: Flushing for devices should be purely a kernel internal
> -   interface on top of dma-buf. flush_for_device needs to be added to dma-buf
> -   first.
> - - Remove ION_IOC_CUSTOM: Atm used for cache flushing for cpu access in some
> -   vendor trees. Should be replaced with an ioctl on the dma-buf to expose the
> -   begin/end_cpu_access hooks to userspace.
> - - Clarify the tricks ion plays with explicitly managing coherency behind the
> -   dma api's back (this is absolutely needed for high-perf gpu drivers): Add an
> -   explicit coherency management mode to flush_for_device to be used by drivers
> -   which want to manage caches themselves and which indicates whether cpu caches
> -   need flushing.
> - - With those removed there's probably no use for ION_IOC_IMPORT anymore either
> -   since ion would just be the central allocator for shared buffers.
> - - Add dt-binding to expose cma regions as ion heaps, with the rule that any
> -   such cma regions must already be used by some device for dma. I.e. ion only
> -   exposes existing cma regions and doesn't reserve unecessarily memory when
> -   booting a system which doesn't use ion.
> + - Add dt-bindings for remaining heaps (chunk and carveout heaps). This would
> +   involve putting appropriate bindings in a memory node for Ion to find.
> + - Split /dev/ion up into multiple nodes (e.g. /dev/ion/heap0)
> + - Better test framework (integration with VGEM was suggested)

Found another one: Integrate the ion kernel-doc into
Documenation/gpu/ion.rst and link it up within Documenation/gpu/index.rst.
There's a lot of api and overview stuff already around, would be great to
make this more accessible.

But I wouldn't put this as a de-staging blocker, just an idea.

On the series: Acked-by: Daniel Vetter <daniel.vetter@ffwll.ch>

No full review since a bunch of stuff I'm not too familiar with, but I
like where this is going.
-Daniel

>  
>  Please send patches to Greg Kroah-Hartman <greg@kroah.com> and Cc:
>  Arve Hjonnevag <arve@android.com> and Riley Andrews <riandrews@android.com>
> -- 
> 2.7.4
> 
> _______________________________________________
> Linaro-mm-sig mailing list
> Linaro-mm-sig@lists.linaro.org
> https://lists.linaro.org/mailman/listinfo/linaro-mm-sig

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
