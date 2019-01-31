Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9023C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 22:14:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 637F220B1F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 22:14:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 637F220B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2ACD8E0003; Thu, 31 Jan 2019 17:14:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB2E68E0001; Thu, 31 Jan 2019 17:14:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A53C88E0003; Thu, 31 Jan 2019 17:14:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC9F8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 17:14:50 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id bj3so3407537plb.17
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:14:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aBrPxwwn7RJKR/O+jeY3kSa8duFxeNwGaiLdCV3OY6Q=;
        b=qN3AdkVXD90o3MUNzQ5BwXjVKfCqInrqsxOf0BIH1SXpvq4CM7T17tRoad6Gv8fWCh
         sd7+/JzXJYrbzghjfNlVfz09+WnGHwOJohGW8Ar0z7DS53f7hmIdPE9hvQvnmr0/bApo
         85nsbtTGkJhJjAEnmvXQhkII73VbojRsvESMztTZ6SZzFutFnqj4kAW8CL83ui8aY3em
         ze9AiFCVZITW7DmKVgrGKZSVz/495yf0yvlKKPGp1CXOuSCErTPIU9Gyu+S9apCa+48e
         ui/ZstWx7ZSX/GpCw5k98+LwtyoevfrxjNnd/f9v5cMHeN0ob1vilSl04sVWCuO3VM1g
         wyFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukcMXhZXz6PgVI/Z0f9ymt6oAP1dRo1o1nTLycclk6u84sxbSE0o
	dqAEy7AioUuDHUrR593M1SrKubLYndNt9mJt1GzlljmpgX+lS3VXnv2kc1tWycjxJw3sY1hq38O
	joS9EpaRIbO2meLD7GWVWhAvet4CQRGubZlndWayQQGW2M7BI9cWyYt7M2PthQYSF7Q==
X-Received: by 2002:a65:590b:: with SMTP id f11mr33423808pgu.60.1548972889951;
        Thu, 31 Jan 2019 14:14:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN47v+f4Uw+0OSLLGAz9RGHDesywyYItXChoUEg2GVMOKQQrfinFHtDFzwVPLnJtXzFjN7mD
X-Received: by 2002:a65:590b:: with SMTP id f11mr33423725pgu.60.1548972888430;
        Thu, 31 Jan 2019 14:14:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548972888; cv=none;
        d=google.com; s=arc-20160816;
        b=FEYyliFhydrNtKnjGrEE6oPnfaa21I8cgV001ggCpWqgqmEdO9P0s0R6lc35voYaLF
         vzJSzm16/ErUdCM+28eCq+Cs9kZ6gDGEC95hiQn+EOY1SQZu1LM9q9vfuBh9Hoye9XoM
         Bz93hBT+a5P5jY4kpq51IITie7fmy6MVIiKgw8qcmR/lRwR+Pg1GSdDAO1X/gthZ5AqO
         p44D4CBMBiUZYLlXtAj8/+q/SpmxQJAnMSGabxguzaTIpvyvkaHBurlyN3a9Wq56IxZ/
         iufl8sToO+KH6csCxca7EcPRWPP+RFgITxzxmEmqot/Zl33awLNo4xCjQZPUeZws1WKm
         BAgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=aBrPxwwn7RJKR/O+jeY3kSa8duFxeNwGaiLdCV3OY6Q=;
        b=V2GixOVus9XyfwrQj870aZHky+yGime9QjIKsUlKhf4U1SLC3k2qgQApvoFwL/nHkP
         t42t2s8nySzT/FfwdThBMKQ5gb0oHclIR3sIw42vPlkYsM3dLXmL5/DA+cfXBFsYmeWP
         2pgmA6EhFAt6gUk2R5CEJIdltyT2GuueeGJWRPf4EKu8cGL7H2h/GWmt3yQQO8klUoCu
         Ay0HX6JBA8mQPfOGpD/VnmEFpiux8nqtfZSSh8Jia1A0IKtcBC28T6dOSggqcipN1WYg
         bb/ZGi6OaxnnCXRTMnvxe1803eyPkp4Hkt8AxEK1JrrC/Ne0XOjYbRbqVFlw5r39DsgY
         lqXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k26si5551202pgb.72.2019.01.31.14.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 14:14:48 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id A4BC14E44;
	Thu, 31 Jan 2019 22:14:47 +0000 (UTC)
Date: Thu, 31 Jan 2019 14:14:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Kees
 Cook <keescook@chromium.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
Message-Id: <20190131141446.46fe7019378ac064dff9183e@linux-foundation.org>
In-Reply-To: <154882453604.1338686.15108059741397800728.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
	<154882453604.1338686.15108059741397800728.stgit@dwillia2-desk3.amr.corp.intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2019 21:02:16 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> Randomization of the page allocator improves the average utilization of
> a direct-mapped memory-side-cache. Memory side caching is a platform
> capability that Linux has been previously exposed to in HPC
> (high-performance computing) environments on specialty platforms. In
> that instance it was a smaller pool of high-bandwidth-memory relative to
> higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> be found on general purpose server platforms where DRAM is a cache in
> front of higher latency persistent memory [1].
> 
> Robert offered an explanation of the state of the art of Linux
> interactions with memory-side-caches [2], and I copy it here:
> 
>     It's been a problem in the HPC space:
>     http://www.nersc.gov/research-and-development/knl-cache-mode-performance-coe/
> 
>     A kernel module called zonesort is available to try to help:
>     https://software.intel.com/en-us/articles/xeon-phi-software
> 
>     and this abandoned patch series proposed that for the kernel:
>     https://lkml.kernel.org/r/20170823100205.17311-1-lukasz.daniluk@intel.com
> 
>     Dan's patch series doesn't attempt to ensure buffers won't conflict, but
>     also reduces the chance that the buffers will. This will make performance
>     more consistent, albeit slower than "optimal" (which is near impossible
>     to attain in a general-purpose kernel).  That's better than forcing
>     users to deploy remedies like:
>         "To eliminate this gradual degradation, we have added a Stream
>          measurement to the Node Health Check that follows each job;
>          nodes are rebooted whenever their measured memory bandwidth
>          falls below 300 GB/s."
> 
> A replacement for zonesort was merged upstream in commit cc9aec03e58f
> "x86/numa_emulation: Introduce uniform split capability". With this
> numa_emulation capability, memory can be split into cache sized
> ("near-memory" sized) numa nodes. A bind operation to such a node, and
> disabling workloads on other nodes, enables full cache performance.
> However, once the workload exceeds the cache size then cache conflicts
> are unavoidable. While HPC environments might be able to tolerate
> time-scheduling of cache sized workloads, for general purpose server
> platforms, the oversubscribed cache case will be the common case.
> 
> The worst case scenario is that a server system owner benchmarks a
> workload at boot with an un-contended cache only to see that performance
> degrade over time, even below the average cache performance due to
> excessive conflicts. Randomization clips the peaks and fills in the
> valleys of cache utilization to yield steady average performance.
> 
> Here are some performance impact details of the patches:
> 
> 1/ An Intel internal synthetic memory bandwidth measurement tool, saw a
> 3X speedup in a contrived case that tries to force cache conflicts. The
> contrived cased used the numa_emulation capability to force an instance
> of the benchmark to be run in two of the near-memory sized numa nodes.
> If both instances were placed on the same emulated they would fit and
> cause zero conflicts.  While on separate emulated nodes without
> randomization they underutilized the cache and conflicted unnecessarily
> due to the in-order allocation per node.
> 
> 2/ A well known Java server application benchmark was run with a heap
> size that exceeded cache size by 3X. The cache conflict rate was 8% for
> the first run and degraded to 21% after page allocator aging. With
> randomization enabled the rate levelled out at 11%.
> 
> 3/ A MongoDB workload did not observe measurable difference in
> cache-conflict rates, but the overall throughput dropped by 7% with
> randomization in one case.
> 
> 4/ Mel Gorman ran his suite of performance workloads with randomization
> enabled on platforms without a memory-side-cache and saw a mix of some
> improvements and some losses [3].
> 
> While there is potentially significant improvement for applications that
> depend on low latency access across a wide working-set, the performance
> may be negligible to negative for other workloads. For this reason the
> shuffle capability defaults to off unless a direct-mapped
> memory-side-cache is detected. Even then, the page_alloc.shuffle=0
> parameter can be specified to disable the randomization on those
> systems.
> 
> Outside of memory-side-cache utilization concerns there is potentially
> security benefit from randomization. Some data exfiltration and
> return-oriented-programming attacks rely on the ability to infer the
> location of sensitive data objects. The kernel page allocator,
> especially early in system boot, has predictable first-in-first out
> behavior for physical pages. Pages are freed in physical address order
> when first onlined.
> 
> Quoting Kees:
>     "While we already have a base-address randomization
>      (CONFIG_RANDOMIZE_MEMORY), attacks against the same hardware and
>      memory layouts would certainly be using the predictability of
>      allocation ordering (i.e. for attacks where the base address isn't
>      important: only the relative positions between allocated memory).
>      This is common in lots of heap-style attacks. They try to gain
>      control over ordering by spraying allocations, etc.
> 
>      I'd really like to see this because it gives us something similar
>      to CONFIG_SLAB_FREELIST_RANDOM but for the page allocator."
> 
> While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
> caches it leaves vast bulk of memory to be predictably in order
> allocated.  However, it should be noted, the concrete security benefits
> are hard to quantify, and no known CVE is mitigated by this
> randomization.
> 
> Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
> perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
> when they are initially populated with free memory at boot and at
> hotplug time. Do this based on either the presence of a
> page_alloc.shuffle=Y command line parameter, or autodetection of a
> memory-side-cache (to be added in a follow-on patch).

This is unfortunate from a testing and coverage point of view.  At
least initially it is desirable that all testers run this feature.

Also, it's unfortunate that enableing the feature requires a reboot. 
What happens if we do away with the boot-time (and maybe hotplug-time)
randomization and permit the feature to be switched on/off at runtime?

> The shuffling is done in terms of CONFIG_SHUFFLE_PAGE_ORDER sized free
> pages where the default CONFIG_SHUFFLE_PAGE_ORDER is MAX_ORDER-1 i.e.
> 10, 4MB this trades off randomization granularity for time spent
> shuffling.  MAX_ORDER-1 was chosen to be minimally invasive to the page
> allocator while still showing memory-side cache behavior improvements,
> and the expectation that the security implications of finer granularity
> randomization is mitigated by CONFIG_SLAB_FREELIST_RANDOM.
> 
> The performance impact of the shuffling appears to be in the noise
> compared to other memory initialization work. Also the bulk of the work
> is done in the background as a part of deferred_init_memmap().
> 
> This initial randomization can be undone over time so a follow-on patch
> is introduced to inject entropy on page free decisions. It is reasonable
> to ask if the page free entropy is sufficient, but it is not enough due
> to the in-order initial freeing of pages. At the start of that process
> putting page1 in front or behind page0 still keeps them close together,
> page2 is still near page1 and has a high chance of being adjacent. As
> more pages are added ordering diversity improves, but there is still
> high page locality for the low address pages and this leads to no
> significant impact to the cache conflict rate.
> 
> ...
>
>  include/linux/list.h    |   17 ++++
>  include/linux/mmzone.h  |    4 +
>  include/linux/shuffle.h |   45 +++++++++++
>  init/Kconfig            |   23 ++++++
>  mm/Makefile             |    7 ++
>  mm/memblock.c           |    1 
>  mm/memory_hotplug.c     |    3 +
>  mm/page_alloc.c         |    6 +-
>  mm/shuffle.c            |  188 +++++++++++++++++++++++++++++++++++++++++++++++

Can we get a Documentation update for the new kernel parameter?

> 
> ...
>
> --- /dev/null
> +++ b/mm/shuffle.c
> @@ -0,0 +1,188 @@
> +// SPDX-License-Identifier: GPL-2.0
> +// Copyright(c) 2018 Intel Corporation. All rights reserved.
> +
> +#include <linux/mm.h>
> +#include <linux/init.h>
> +#include <linux/mmzone.h>
> +#include <linux/random.h>
> +#include <linux/shuffle.h>

Does shuffle.h need to be available to the whole kernel or can we put
it in mm/?

> +#include <linux/moduleparam.h>
> +#include "internal.h"
> +
> +DEFINE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
> +static unsigned long shuffle_state __ro_after_init;
> +
> +/*
> + * Depending on the architecture, module parameter parsing may run
> + * before, or after the cache detection. SHUFFLE_FORCE_DISABLE prevents,
> + * or reverts the enabling of the shuffle implementation. SHUFFLE_ENABLE
> + * attempts to turn on the implementation, but aborts if it finds
> + * SHUFFLE_FORCE_DISABLE already set.
> + */
> +void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
> +{
> +	if (ctl == SHUFFLE_FORCE_DISABLE)
> +		set_bit(SHUFFLE_FORCE_DISABLE, &shuffle_state);
> +
> +	if (test_bit(SHUFFLE_FORCE_DISABLE, &shuffle_state)) {
> +		if (test_and_clear_bit(SHUFFLE_ENABLE, &shuffle_state))
> +			static_branch_disable(&page_alloc_shuffle_key);
> +	} else if (ctl == SHUFFLE_ENABLE
> +			&& !test_and_set_bit(SHUFFLE_ENABLE, &shuffle_state))
> +		static_branch_enable(&page_alloc_shuffle_key);
> +}

Can this be __meminit?

> +static bool shuffle_param;
> +extern int shuffle_show(char *buffer, const struct kernel_param *kp)
> +{
> +	return sprintf(buffer, "%c\n", test_bit(SHUFFLE_ENABLE, &shuffle_state)
> +			? 'Y' : 'N');
> +}
> +static int shuffle_store(const char *val, const struct kernel_param *kp)
> +{
> +	int rc = param_set_bool(val, kp);
> +
> +	if (rc < 0)
> +		return rc;
> +	if (shuffle_param)
> +		page_alloc_shuffle(SHUFFLE_ENABLE);
> +	else
> +		page_alloc_shuffle(SHUFFLE_FORCE_DISABLE);
> +	return 0;
> +}
> +module_param_call(shuffle, shuffle_store, shuffle_show, &shuffle_param, 0400);
> 
> ...
>
> +/*
> + * Fisher-Yates shuffle the freelist which prescribes iterating through
> + * an array, pfns in this case, and randomly swapping each entry with
> + * another in the span, end_pfn - start_pfn.
> + *
> + * To keep the implementation simple it does not attempt to correct for
> + * sources of bias in the distribution, like modulo bias or
> + * pseudo-random number generator bias. I.e. the expectation is that
> + * this shuffling raises the bar for attacks that exploit the
> + * predictability of page allocations, but need not be a perfect
> + * shuffle.

Reflowing the comment to use all 80 cols would save a line :)

> + */
> +#define SHUFFLE_RETRY 10
> +void __meminit __shuffle_zone(struct zone *z)
> +{
> +	unsigned long i, flags;
> +	unsigned long start_pfn = z->zone_start_pfn;
> +	unsigned long end_pfn = zone_end_pfn(z);
> +	const int order = SHUFFLE_ORDER;
> +	const int order_pages = 1 << order;
> +
> +	spin_lock_irqsave(&z->lock, flags);
> +	start_pfn = ALIGN(start_pfn, order_pages);
> +	for (i = start_pfn; i < end_pfn; i += order_pages) {
> +		unsigned long j;
> +		int migratetype, retry;
> +		struct page *page_i, *page_j;
> +
> +		/*
> +		 * We expect page_i, in the sub-range of a zone being
> +		 * added (@start_pfn to @end_pfn), to more likely be
> +		 * valid compared to page_j randomly selected in the
> +		 * span @zone_start_pfn to @spanned_pages.
> +		 */
> +		page_i = shuffle_valid_page(i, order);
> +		if (!page_i)
> +			continue;
> +
> +		for (retry = 0; retry < SHUFFLE_RETRY; retry++) {
> +			/*
> +			 * Pick a random order aligned page from the
> +			 * start of the zone. Use the *whole* zone here
> +			 * so that if it is freed in tiny pieces that we
> +			 * randomize in the whole zone, not just within
> +			 * those fragments.

Second sentence is hard to parse.

> +			 *
> +			 * Since page_j comes from a potentially sparse
> +			 * address range we want to try a bit harder to
> +			 * find a shuffle point for page_i.
> +			 */

Reflow the comment...

> +			j = z->zone_start_pfn +
> +				ALIGN_DOWN(get_random_long() % z->spanned_pages,
> +						order_pages);
> +			page_j = shuffle_valid_page(j, order);
> +			if (page_j && page_j != page_i)
> +				break;
> +		}
> +		if (retry >= SHUFFLE_RETRY) {
> +			pr_debug("%s: failed to swap %#lx\n", __func__, i);
> +			continue;
> +		}
> +
> +		/*
> +		 * Each migratetype corresponds to its own list, make
> +		 * sure the types match otherwise we're moving pages to
> +		 * lists where they do not belong.
> +		 */

Reflow.

> +		migratetype = get_pageblock_migratetype(page_i);
> +		if (get_pageblock_migratetype(page_j) != migratetype) {
> +			pr_debug("%s: migratetype mismatch %#lx\n", __func__, i);
> +			continue;
> +		}
> +
> +		list_swap(&page_i->lru, &page_j->lru);
> +
> +		pr_debug("%s: swap: %#lx -> %#lx\n", __func__, i, j);
> +
> +		/* take it easy on the zone lock */
> +		if ((i % (100 * order_pages)) == 0) {
> +			spin_unlock_irqrestore(&z->lock, flags);
> +			cond_resched();
> +			spin_lock_irqsave(&z->lock, flags);
> +		}
> +	}
> +	spin_unlock_irqrestore(&z->lock, flags);
> +}
> 
> ...
>

