Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1918EC282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 23:05:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0BC120B1F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 23:05:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="CIgVdd1t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0BC120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A1958E0002; Thu, 31 Jan 2019 18:05:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34FFF8E0001; Thu, 31 Jan 2019 18:05:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 266DE8E0002; Thu, 31 Jan 2019 18:05:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED21E8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 18:05:11 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id o8so2119741otp.16
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 15:05:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IdXD3uZ2L841UOk0sPP0q0UD/Q+2rpbv1w50WYHpA7Y=;
        b=Edn6dl8LKfPvT5uz+YjagwjigP2j8Uul4VRXTPMDTdwbqZEjhWoVyCWO0YyV5j0bFg
         qIfowD1pEXfuc9Fr8uqT5WDQl+2TWjihFGsbtSZOH15JMKrzZ/WaNhonFWzkpcRbhaE3
         +EAM1Tgzjhs8vwsoKKT0qLsRIeBqAQmmO7Fx18hLYOw9v4GNfOBIRbvXwvmZFhSU2nkr
         uOaO6spv2qLrA6Qz8pobCxsEOe61UbbiCHIrZIvQuL1c4ScigWXvgn6RJ0CvPzZyfzrj
         hhe/dLyy/48NmLcvJq7B6Qd3gqAoRH7pjz0eKXL8MHoQBdifmjGnO8zFC2vVf+G+dfl0
         9ZfQ==
X-Gm-Message-State: AHQUAuZh8ZdvutvZfeVMX0wXdgUQJMnjwkCRe+BjV66bLFESQdx4KRBx
	IImxo6OqFDUQ3JrpfyMSfsfKA59Nitb9kAd2zSVoC+1jRyMZBUZ3kpI5BoS6IaIecccw2ywnxqr
	azRUWmF2bi3ugvXBQQ+uoaz2MmGVJ4bR0d0+4IAXKxxUx9XRBi7vYSPyU28KjP1ZVJbtBFJlnuy
	uNIKUr4u9t8zDXMtH32e2O4iKM4Cn5sRs6jJYo3hj8K4u+gAsX+SxXbTcnxt2RI3qZG30W4564G
	FQzMgIl2Mtakh5SHF2L6lFvEYsSQ8GRrvDllCPpCinPI0eEjk9pgkEkwaOxw7ZcbDz5mRlDuPig
	u7xJKTblFBiWQb5KEZHxhvjYoT9VGlI2OrF9bm5oQ4Nz6sfRHGqezSJpcr0OPOjE7J4bnMfde5/
	C
X-Received: by 2002:aca:c649:: with SMTP id w70mr16936520oif.186.1548975911542;
        Thu, 31 Jan 2019 15:05:11 -0800 (PST)
X-Received: by 2002:aca:c649:: with SMTP id w70mr16936469oif.186.1548975910247;
        Thu, 31 Jan 2019 15:05:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548975910; cv=none;
        d=google.com; s=arc-20160816;
        b=0aqQkys8iF3pXpzEFlQOIVs5RUxLKcdub2lNXOflDwhXfTtmhuLfdqAzrra8CWljgp
         CjZNonFK+X/6TjFC4P+N1VK7GWsCDolTl2pDvXuBQ44KmLVK1qMm5CRMX/e+XAy/3Zu5
         1II7LiGjj4aZ+nxSETBcAojYAQmanWp1FR0u55aXixaP6+BhpSvub9FQCu99OLIM5VRZ
         s59DoSIGmlrQjDRg090jquxmqP8KIVXuTp3i8EPlxy3qp4I6T686ee0bhSEV8kp0I2/a
         0PGp3B70O6Dqhg47f6/8/h2302UYjcQQwfu/xddV5zlUPvKDgynVSBXqQWio6TiPA4E5
         s9Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IdXD3uZ2L841UOk0sPP0q0UD/Q+2rpbv1w50WYHpA7Y=;
        b=PSgXhSocyhm77JWvc1V7a1qj4F4DNZAeyDWhhWfgD8uLsqy1CHPLJ11FwjYFEy/YOK
         vvEwKH7uZCKbZbaV4wRVcjXswYX35ig52vwYlJ/9fTshSJzkslp2vatJ+ZvY006DpK+c
         hvJcLfEFB48192rc6oHMCSNMG6slL25Pe8VOeSSpUGVmY2cBFLoW9mgcChQd2ggcLgZQ
         Z5QYNcU3slQ0vUsRjrn9Ab+m7mXt3QzR1YKUogvM7kK4zhQozHP/ef4twxBMzAqhkJpo
         LDyfuRVQ+yW/WBlcHMxbjaZJY43tRx+IM1VLGnOHwAI8kvc9qjinydoTncxmvJ8srxJX
         3ymQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=CIgVdd1t;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o132sor2995350oia.37.2019.01.31.15.05.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Jan 2019 15:05:09 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=CIgVdd1t;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IdXD3uZ2L841UOk0sPP0q0UD/Q+2rpbv1w50WYHpA7Y=;
        b=CIgVdd1tvOZzE3FTNSfE9Yk4Ew3Bf9EtJCna1lL2Rhm1kKBpRZo9nDWDDuKx/yumYp
         4vo+Ecdjpwgy7PuC3VHxnwDn++z0XBKTBQLQXhd+t8iL+DOwDeKnsfUSTvHxoYsGCgTi
         vYRPhSKi9hUgHYdBRIoU7tji4CbwFOE99w0YQopd7Xt8nu+fPCjNe3jHkCO3b1icJ3I3
         Fberkqa1Hk+YiWkBL5hDTc6otGMNgIvarS2fpiKMoRwHyf78BSaj4u7NiWtWZYs09lMu
         GLbAw2u7YfL4npA0PH6oJNw9gsbWmkbBuPIZg24rc/R/YLvuCu6Q/LPJTH4PEsBj13tx
         LZTQ==
X-Google-Smtp-Source: AHgI3IacsTWl2N+gqmbMmrekSxGgAFl4u02GPxjzIIoSl+UjevF3llu60gUhEqgINppnRd57XIipYOddHj+cJDRYGm8=
X-Received: by 2002:aca:d78b:: with SMTP id o133mr15867430oig.232.1548975909522;
 Thu, 31 Jan 2019 15:05:09 -0800 (PST)
MIME-Version: 1.0
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154882453604.1338686.15108059741397800728.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190131141446.46fe7019378ac064dff9183e@linux-foundation.org>
In-Reply-To: <20190131141446.46fe7019378ac064dff9183e@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 31 Jan 2019 15:04:57 -0800
Message-ID: <CAPcyv4ieyORm_rTXF0AACx4qX06E1xCmM-0SpsrpN5D+9W-zUQ@mail.gmail.com>
Subject: Re: [PATCH v9 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Kees Cook <keescook@chromium.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 2:15 PM Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 29 Jan 2019 21:02:16 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
[..]
> > Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
> > perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
> > when they are initially populated with free memory at boot and at
> > hotplug time. Do this based on either the presence of a
> > page_alloc.shuffle=Y command line parameter, or autodetection of a
> > memory-side-cache (to be added in a follow-on patch).
>
> This is unfortunate from a testing and coverage point of view.  At
> least initially it is desirable that all testers run this feature.
>
> Also, it's unfortunate that enableing the feature requires a reboot.
> What happens if we do away with the boot-time (and maybe hotplug-time)
> randomization and permit the feature to be switched on/off at runtime?

Currently there's the 'shuffle' at memory online time and a random
front-back freeing of max_order pages to the free lists at runtime.
The random front-back freeing behavior would be trivial to toggle at
runtime, however testing showed that the entropy it injects is only
enough to preserve the randomization of the initial 'shuffle', but not
enough entropy to improve cache utilization on its own.

The shuffling could be done dynamically at runtime, but it only
shuffles free memory, the effectiveness is diminished if the workload
has already taken pages off the free list. It's also diminished if the
free lists are polluted with sub MAX_ORDER pages.

The number of caveats that need to be documented makes me skeptical
that runtime triggered shuffling would be reliable.

That said, I see your point about experimentation and validation. What
about allowing it to be settable as a sysfs parameter for
memory-blocks that are being hot-added? That way we know the shuffle
will be effective and the administrator can validate shuffling with a
hot-unplug/replug?

> > The shuffling is done in terms of CONFIG_SHUFFLE_PAGE_ORDER sized free
> > pages where the default CONFIG_SHUFFLE_PAGE_ORDER is MAX_ORDER-1 i.e.
> > 10, 4MB this trades off randomization granularity for time spent
> > shuffling.  MAX_ORDER-1 was chosen to be minimally invasive to the page
> > allocator while still showing memory-side cache behavior improvements,
> > and the expectation that the security implications of finer granularity
> > randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM.
> >
> > The performance impact of the shuffling appears to be in the noise
> > compared to other memory initialization work. Also the bulk of the work
> > is done in the background as a part of deferred_init_memmap().
> >
> > This initial randomization can be undone over time so a follow-on patch
> > is introduced to inject entropy on page free decisions. It is reasonable
> > to ask if the page free entropy is sufficient, but it is not enough due
> > to the in-order initial freeing of pages. At the start of that process
> > putting page1 in front or behind page0 still keeps them close together,
> > page2 is still near page1 and has a high chance of being adjacent. As
> > more pages are added ordering diversity improves, but there is still
> > high page locality for the low address pages and this leads to no
> > significant impact to the cache conflict rate.
> >
> > ...
> >
> >  include/linux/list.h    |   17 ++++
> >  include/linux/mmzone.h  |    4 +
> >  include/linux/shuffle.h |   45 +++++++++++
> >  init/Kconfig            |   23 ++++++
> >  mm/Makefile             |    7 ++
> >  mm/memblock.c           |    1
> >  mm/memory_hotplug.c     |    3 +
> >  mm/page_alloc.c         |    6 +-
> >  mm/shuffle.c            |  188 +++++++++++++++++++++++++++++++++++++++++++++++
>
> Can we get a Documentation update for the new kernel parameter?

Yes.

>
> >
> > ...
> >
> > --- /dev/null
> > +++ b/mm/shuffle.c
> > @@ -0,0 +1,188 @@
> > +// SPDX-License-Identifier: GPL-2.0
> > +// Copyright(c) 2018 Intel Corporation. All rights reserved.
> > +
> > +#include <linux/mm.h>
> > +#include <linux/init.h>
> > +#include <linux/mmzone.h>
> > +#include <linux/random.h>
> > +#include <linux/shuffle.h>
>
> Does shuffle.h need to be available to the whole kernel or can we put
> it in mm/?

The wider kernel just needs page_alloc_shuffle() so that
platform-firmware parsing code that detects a memory-side-cache can
enable the shuffle. The rest can be constrained to an mm/ local
header.

>
> > +#include <linux/moduleparam.h>
> > +#include "internal.h"
> > +
> > +DEFINE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
> > +static unsigned long shuffle_state __ro_after_init;
> > +
> > +/*
> > + * Depending on the architecture, module parameter parsing may run
> > + * before, or after the cache detection. SHUFFLE_FORCE_DISABLE prevents,
> > + * or reverts the enabling of the shuffle implementation. SHUFFLE_ENABLE
> > + * attempts to turn on the implementation, but aborts if it finds
> > + * SHUFFLE_FORCE_DISABLE already set.
> > + */
> > +void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
> > +{
> > +     if (ctl == SHUFFLE_FORCE_DISABLE)
> > +             set_bit(SHUFFLE_FORCE_DISABLE, &shuffle_state);
> > +
> > +     if (test_bit(SHUFFLE_FORCE_DISABLE, &shuffle_state)) {
> > +             if (test_and_clear_bit(SHUFFLE_ENABLE, &shuffle_state))
> > +                     static_branch_disable(&page_alloc_shuffle_key);
> > +     } else if (ctl == SHUFFLE_ENABLE
> > +                     && !test_and_set_bit(SHUFFLE_ENABLE, &shuffle_state))
> > +             static_branch_enable(&page_alloc_shuffle_key);
> > +}
>
> Can this be __meminit?

Yes.

>
> > +static bool shuffle_param;
> > +extern int shuffle_show(char *buffer, const struct kernel_param *kp)
> > +{
> > +     return sprintf(buffer, "%c\n", test_bit(SHUFFLE_ENABLE, &shuffle_state)
> > +                     ? 'Y' : 'N');
> > +}
> > +static int shuffle_store(const char *val, const struct kernel_param *kp)
> > +{
> > +     int rc = param_set_bool(val, kp);
> > +
> > +     if (rc < 0)
> > +             return rc;
> > +     if (shuffle_param)
> > +             page_alloc_shuffle(SHUFFLE_ENABLE);
> > +     else
> > +             page_alloc_shuffle(SHUFFLE_FORCE_DISABLE);
> > +     return 0;
> > +}
> > +module_param_call(shuffle, shuffle_store, shuffle_show, &shuffle_param, 0400);
> >
> > ...
> >
> > +/*
> > + * Fisher-Yates shuffle the freelist which prescribes iterating through
> > + * an array, pfns in this case, and randomly swapping each entry with
> > + * another in the span, end_pfn - start_pfn.
> > + *
> > + * To keep the implementation simple it does not attempt to correct for
> > + * sources of bias in the distribution, like modulo bias or
> > + * pseudo-random number generator bias. I.e. the expectation is that
> > + * this shuffling raises the bar for attacks that exploit the
> > + * predictability of page allocations, but need not be a perfect
> > + * shuffle.
>
> Reflowing the comment to use all 80 cols would save a line :)

WIll do.

>
> > + */
> > +#define SHUFFLE_RETRY 10
> > +void __meminit __shuffle_zone(struct zone *z)
> > +{
> > +     unsigned long i, flags;
> > +     unsigned long start_pfn = z->zone_start_pfn;
> > +     unsigned long end_pfn = zone_end_pfn(z);
> > +     const int order = SHUFFLE_ORDER;
> > +     const int order_pages = 1 << order;
> > +
> > +     spin_lock_irqsave(&z->lock, flags);
> > +     start_pfn = ALIGN(start_pfn, order_pages);
> > +     for (i = start_pfn; i < end_pfn; i += order_pages) {
> > +             unsigned long j;
> > +             int migratetype, retry;
> > +             struct page *page_i, *page_j;
> > +
> > +             /*
> > +              * We expect page_i, in the sub-range of a zone being
> > +              * added (@start_pfn to @end_pfn), to more likely be
> > +              * valid compared to page_j randomly selected in the
> > +              * span @zone_start_pfn to @spanned_pages.
> > +              */
> > +             page_i = shuffle_valid_page(i, order);
> > +             if (!page_i)
> > +                     continue;
> > +
> > +             for (retry = 0; retry < SHUFFLE_RETRY; retry++) {
> > +                     /*
> > +                      * Pick a random order aligned page from the
> > +                      * start of the zone. Use the *whole* zone here
> > +                      * so that if it is freed in tiny pieces that we
> > +                      * randomize in the whole zone, not just within
> > +                      * those fragments.
>
> Second sentence is hard to parse.

Earlier versions only arranged to shuffle over non-hole ranges, but
the SHUFFLE_RETRY works around that now. I'll update the comment.

>
> > +                      *
> > +                      * Since page_j comes from a potentially sparse
> > +                      * address range we want to try a bit harder to
> > +                      * find a shuffle point for page_i.
> > +                      */
>
> Reflow the comment...

yup.

>
> > +                     j = z->zone_start_pfn +
> > +                             ALIGN_DOWN(get_random_long() % z->spanned_pages,
> > +                                             order_pages);
> > +                     page_j = shuffle_valid_page(j, order);
> > +                     if (page_j && page_j != page_i)
> > +                             break;
> > +             }
> > +             if (retry >= SHUFFLE_RETRY) {
> > +                     pr_debug("%s: failed to swap %#lx\n", __func__, i);
> > +                     continue;
> > +             }
> > +
> > +             /*
> > +              * Each migratetype corresponds to its own list, make
> > +              * sure the types match otherwise we're moving pages to
> > +              * lists where they do not belong.
> > +              */
>
> Reflow.

ok.

