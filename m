Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 65B886B004D
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 05:32:29 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id u15so2461543bkz.19
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 02:32:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id yh8si10653509bkb.144.2013.11.26.02.32.28
        for <linux-mm@kvack.org>;
        Tue, 26 Nov 2013 02:32:28 -0800 (PST)
Date: Tue, 26 Nov 2013 10:32:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: NUMA? bisected performance regression 3.11->3.12
Message-ID: <20131126103223.GG5285@suse.de>
References: <528E8FCE.1000707@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <528E8FCE.1000707@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Kevin Hilman <khilman@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Paul Bolle <paul.bollee@gmail.com>, Zlatko Calusic <zcalusic@bitsync.net>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Nov 21, 2013 at 02:57:18PM -0800, Dave Hansen wrote:
> Hey Johannes,
> 
> I'm running an open/close microbenchmark from the will-it-scale set:
> > https://github.com/antonblanchard/will-it-scale/blob/master/tests/open1.c
> 
> I was seeing some weird symptoms on 3.12 vs 3.11.  The throughput in
> that test was going from down from 50 million to 35 million.
> 
> The profiles show an increase in cpu time in _raw_spin_lock_irq.  The
> profiles pointed to slub code that hasn't been touched in quite a while.
>  I bisected it down to:
> 

Dave, do you mind retesting this against "[RFC PATCH 0/5] Memory compaction
efficiency improvements" please? I have not finished reviewing the series
yet but patch 3 mentions lower allocation success rates with Johannes'
patch and notes that it is unlikely to be a bug with the patch itself.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
