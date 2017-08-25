Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A590F6810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 17:42:00 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p8so1409062wrf.2
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 14:42:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x8si1928326wme.29.2017.08.25.14.41.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 14:41:59 -0700 (PDT)
Date: Fri, 25 Aug 2017 14:41:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: Track actual nr_scanned during shrink_slab()
Message-Id: <20170825144156.f70bfad8dd982d1a320e41ca@linux-foundation.org>
In-Reply-To: <29aae2cd-85a8-f3c4-66e2-4d4f5a2732c1@suse.cz>
References: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
	<20170822135325.9191-1-chris@chris-wilson.co.uk>
	<20170824051153.GB13922@bgram>
	<29aae2cd-85a8-f3c4-66e2-4d4f5a2732c1@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

On Thu, 24 Aug 2017 10:00:49 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> > Even if a
> > shrinker has a mistake, VM will have big trouble like infinite loop.
> 
> We could fake 0 as 1 or something, at least.

If the shrinker returns sc->nr_scanned==0 then that's a buggy shrinker
- it should return SHRINK_STOP in that case.  Only a single shrinker
(i915) presently uses sc->nr_scanned and that one gets it right.  I
think it's OK - there's a limit to how far we should go defending
against buggy kernel code, surely.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
