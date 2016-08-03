Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96D686B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 20:39:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so366487689pfx.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 17:39:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o75si5670128pfj.22.2016.08.02.17.39.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 17:39:05 -0700 (PDT)
Date: Tue, 2 Aug 2016 17:39:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 173/210]
 drivers/gpu/drm/i915/intel_display.c:11119:21: error: 'dev' redeclared as
 different kind of symbol
Message-Id: <20160802173904.f3a59ab3c9ff116f98d713a8@linux-foundation.org>
In-Reply-To: <201608030846.n3Y646BU%fengguang.wu@intel.com>
References: <201608030846.n3Y646BU%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 3 Aug 2016 08:03:53 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   572b7c98f12bd2213553be42cc5c2cbc5698f5c3
> commit: a7fd9132464db70c3bb4825d5e7cd5eae33c8f61 [173/210] x86: dma-mapping: use unsigned long for dma_attrs
> config: i386-randconfig-s0-201631 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         git checkout a7fd9132464db70c3bb4825d5e7cd5eae33c8f61
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    drivers/gpu/drm/i915/intel_display.c: In function 'intel_gen2_queue_flip':
> >> drivers/gpu/drm/i915/intel_display.c:11119:21: error: 'dev' redeclared as different kind of symbol
>      struct drm_device *dev = &dev_priv->drm;
>                         ^~~

Thanks.  This was probably the mystery git mismerge which I couldn't be
bothered fixing.  It should come good in the next linux-next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
