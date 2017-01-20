Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2406B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 08:34:08 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so14959816wjy.6
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 05:34:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f186si3441404wma.165.2017.01.20.05.34.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 05:34:07 -0800 (PST)
Subject: Re: Linux 4.10-rc2 arm: dmesg flooded with alloc_contig_range: [X, Y)
 PFNs busy
References: <6c67577e-8b72-c958-40af-2096d8840fbe@osg.samsung.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <db30a1b4-ef1d-3287-3ed0-a9b9c6989ce2@suse.cz>
Date: Fri, 20 Jan 2017 14:34:02 +0100
MIME-Version: 1.0
In-Reply-To: <6c67577e-8b72-c958-40af-2096d8840fbe@osg.samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shuah Khan <shuahkh@osg.samsung.com>, Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Lucas Stach <l.stach@pengutronix.de>

On 01/18/2017 01:23 AM, Shuah Khan wrote:
> Hi,
> 
> dmesg floods with PFNs busy messages.
> 
> [10119.071455] alloc_contig_range: [bb900, bbc00) PFNs busy
> [10119.071631] alloc_contig_range: [bba00, bbd00) PFNs busy
> [10119.071762] alloc_contig_range: [bbb00, bbe00) PFNs busy
> [10119.071940] alloc_contig_range: [bbc00, bbf00) PFNs busy
> [10119.072039] alloc_contig_range: [bbd00, bc000) PFNs busy
> [10119.072188] alloc_contig_range: [bbe00, bc100) PFNs busy
> [10119.072301] alloc_contig_range: [bbf00, bc200) PFNs busy
> [10119.072403] alloc_contig_range: [bc000, bc300) PFNs busy
> [10119.072549] alloc_contig_range: [bc100, bc400) PFNs busy
> [10119.072584] [drm:exynos_drm_gem_create] *ERROR* failed to allocate buffer.
> 
> I think this is triggered when drm tries to allocate CMA buffers.
> I might have seen one or two messages in 4.9, but since 4.10, it
> just floods dmesg.
> 
> Is this a known problem? I am seeing this on odroid-xu4

Hi,

yes most likely it's the problem fixed by this patch in mmotm/linux-next:

http://ozlabs.org/~akpm/mmots/broken-out/mm-alloc_contig-re-allow-cma-to-compact-fs-pages.patch

> Linux odroid 4.10.0-rc2-00251-ge03c755-dirty #12 SMP PREEMPT
> Wed Jan 11 23:12:52 UTC 2017 armv7l armv7l armv7l GNU/Linux
> 
> thanks,
> -- Shuah
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
