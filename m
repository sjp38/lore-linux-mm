Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id A34446B0036
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 01:03:51 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so2684992pbc.20
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:03:51 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ib4si8349965pad.70.2014.06.19.22.03.49
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 22:03:50 -0700 (PDT)
Date: Fri, 20 Jun 2014 14:08:16 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [mmotm:master 108/230] arch/arm/mm/dma-mapping.c:434:54: error:
 'CONFIG_CMA_AREAS' undeclared here (not in a function)
Message-ID: <20140620050816.GA24447@js1304-P5Q-DELUXE>
References: <53a3a239.ebeLDxstWjtov6Pi%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53a3a239.ebeLDxstWjtov6Pi%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Fri, Jun 20, 2014 at 10:53:45AM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   df25ba7db0775d87018e2cd92f26b9b087093840
> commit: a93b0a43ec6787c98ac94f4d391069dddc006ce9 [108/230] CMA: generalize CMA reserved area management functionality
> config: arm-sa1100 (attached as .config)
> 
> All error/warnings:
> 
> >> arch/arm/mm/dma-mapping.c:434:54: error: 'CONFIG_CMA_AREAS' undeclared here (not in a function)
>    arch/arm/mm/dma-mapping.c:434:40: warning: 'dma_mmu_remap' defined but not used [-Wunused-variable]
> 

Hello,

There is a mistake.
Here goes the fix.

Thanks.

-------------------8<---------------
