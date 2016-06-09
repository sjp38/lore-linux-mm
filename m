Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C16A56B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 09:32:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u74so17863772lff.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 06:32:17 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r65si19942598wmd.82.2016.06.09.06.32.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 06:32:16 -0700 (PDT)
Date: Thu, 9 Jun 2016 09:32:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 01/10] mm: allow swappiness that prefers anon over file
Message-ID: <20160609133205.GA11719@cmpxchg.org>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-2-hannes@cmpxchg.org>
 <20160607002550.GA26230@bbox>
 <20160607141818.GE9978@cmpxchg.org>
 <20160608000632.GA27258@bbox>
 <20160608155812.GC6727@cmpxchg.org>
 <20160609010107.GF28620@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160609010107.GF28620@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Thu, Jun 09, 2016 at 10:01:07AM +0900, Minchan Kim wrote:
> A system has big HDD storage and SSD swap.
> 
> HDD:    200 IOPS
> SSD: 100000 IOPS
> From https://en.wikipedia.org/wiki/IOPS
> 
> So, speed gap is 500x.
> x + 500x = 200
> If we use PCIe-SSD, the gap will be larger.
> That's why I said 200 is enough to represent speed gap.

Ah, I see what you're saying.

Yeah, that's unfortunately a limitation in the current ABI. Extending
the range to previously unavailable settings is doable; changing the
meaning of existing values is not. We'd have to add another interface.

> Such system configuration is already non-sense so it is okay to ignore such
> usecases?

I'm not sure we have to be proactive about it, but we can always add a
more fine-grained knob to override swappiness when somebody wants to
use such a setup in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
