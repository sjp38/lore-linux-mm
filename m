Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 956666B0038
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 13:48:00 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so39202893wmf.3
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:48:00 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id r190si27117512wmr.61.2016.11.28.10.47.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 10:47:59 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id B6F8D990CC
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 18:47:58 +0000 (UTC)
Date: Mon, 28 Nov 2016 18:47:58 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
Message-ID: <20161128184758.bcz5ar5svv7whnqi@techsingularity.net>
References: <20161127131954.10026-1-mgorman@techsingularity.net>
 <alpine.DEB.2.20.1611280934460.28989@east.gentwo.org>
 <20161128162126.ulbqrslpahg4wdk3@techsingularity.net>
 <alpine.DEB.2.20.1611281037400.29533@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1611281037400.29533@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Mon, Nov 28, 2016 at 10:38:58AM -0600, Christoph Lameter wrote:
> > > that only insiders know how to tune and an overall fragile solution.
> > While I agree with all of this, it's also a problem independent of this
> > patch.
> 
> It is related. The fundamental issue with fragmentation remain and IMHO we
> really need to tackle this.
> 

Fragmentation is one issue. Allocation scalability is a separate issue.
This patch is about scaling parallel allocations of small contiguous
ranges. Even if there were fragmentation-related patches up for discussion,
they would not be directly affected by this patch.

If you have a series aimed at parts of the fragmentation problem or how
subsystems can avoid tracking 4K pages in some important cases then by
all means post them.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
