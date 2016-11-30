Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B205F6B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:56:02 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so49358600wmw.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 00:56:02 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id p10si62778166wjb.172.2016.11.30.00.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 00:56:00 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 1C32A1C23F6
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 08:56:00 +0000 (GMT)
Date: Wed, 30 Nov 2016 08:55:59 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161130085559.shfdy6mx6lx4fr3i@techsingularity.net>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
 <5621b386-ee65-0fa5-e217-334924412c7f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5621b386-ee65-0fa5-e217-334924412c7f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Mon, Nov 28, 2016 at 12:00:41PM +0100, Vlastimil Babka wrote:
> > 1-socket 6 year old machine
> >                                 4.9.0-rc5             4.9.0-rc5
> >                                   vanilla             hopcpu-v3
> > Hmean    send-64          87.47 (  0.00%)      127.14 ( 45.36%)
> > Hmean    send-128        174.36 (  0.00%)      256.42 ( 47.06%)
> > Hmean    send-256        347.52 (  0.00%)      509.41 ( 46.59%)
> > Hmean    send-1024      1363.03 (  0.00%)     1991.54 ( 46.11%)
> > Hmean    send-2048      2632.68 (  0.00%)     3759.51 ( 42.80%)
> > Hmean    send-3312      4123.19 (  0.00%)     5873.28 ( 42.45%)
> > Hmean    send-4096      5056.48 (  0.00%)     7072.81 ( 39.88%)
> > Hmean    send-8192      8784.22 (  0.00%)    12143.92 ( 38.25%)
> > Hmean    send-16384    15081.60 (  0.00%)    19812.71 ( 31.37%)
> > Hmean    recv-64          86.19 (  0.00%)      126.59 ( 46.87%)
> > Hmean    recv-128        173.93 (  0.00%)      255.21 ( 46.73%)
> > Hmean    recv-256        346.19 (  0.00%)      506.72 ( 46.37%)
> > Hmean    recv-1024      1358.28 (  0.00%)     1980.03 ( 45.77%)
> > Hmean    recv-2048      2623.45 (  0.00%)     3729.35 ( 42.15%)
> > Hmean    recv-3312      4108.63 (  0.00%)     5831.47 ( 41.93%)
> > Hmean    recv-4096      5037.25 (  0.00%)     7021.59 ( 39.39%)
> > Hmean    recv-8192      8762.32 (  0.00%)    12072.44 ( 37.78%)
> > Hmean    recv-16384    15042.36 (  0.00%)    19690.14 ( 30.90%)
> 
> That looks way much better than the "v1" RFC posting. Was it just because
> you stopped doing the "at first iteration, use migratetype as index", and
> initializing pindex UINT_MAX hits so much quicker, or was there something
> more subtle that I missed? There was no changelog between "v1" and "v2".
> 

FYI, the LKP test robot reported the following so there is some
independent basis for picking this up.

---8<---

FYI, we noticed a +23.0% improvement of netperf.Throughput_Mbps due to
commit:

commit 79404c5a5c66481aa55c0cae685e49e0f44a0479 ("mm: page_alloc: High-order per-cpu page allocator")
https://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git mm-pagealloc-highorder-percpu-v3r1


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
