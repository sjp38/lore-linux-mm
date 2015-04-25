Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3F56B0032
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 13:29:06 -0400 (EDT)
Received: by wgen6 with SMTP id n6so78680189wge.3
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 10:29:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cq9si25312031wjc.42.2015.04.25.10.29.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Apr 2015 10:29:04 -0700 (PDT)
Date: Sat, 25 Apr 2015 18:28:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 10/13] x86: mm: Enable deferred struct page
 initialisation on x86-64
Message-ID: <20150425172859.GE2449@suse.de>
References: <1429722473-28118-1-git-send-email-mgorman@suse.de>
 <1429722473-28118-11-git-send-email-mgorman@suse.de>
 <20150422164500.121a355e6b578243cb3650e3@linux-foundation.org>
 <20150423092327.GJ14842@suse.de>
 <553A54C5.3060106@hp.com>
 <20150424152007.GD2449@suse.de>
 <553A93BB.1010404@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <553A93BB.1010404@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Apr 24, 2015 at 03:04:27PM -0400, Waiman Long wrote:
> >>Within a NUMA node, however, we can split the
> >>memory initialization to 2 or more local CPUs if the memory size is
> >>big enough.
> >>
> >I considered it but discarded the idea. It'd be more complex to setup and
> >the two CPUs could simply end up contending on the same memory bus as
> >well as contending on zone->lock.
> >
> 
> I don't think we need that now. However, we may have to consider
> this when one day even a single node can have TBs of memory unless
> we move to a page size larger than 4k.
> 

We'll cross that bridge when we come to it. I suspect there is more room
for improvement in the initialisation that would be worth trying before
resorting to more threads. With more threads there is a risk that we hit
memory bus contention and a high risk that it actually is worse due to
contending on zone->lock when freeing the pages.

In the meantime, do you mind updating the before/after figures for your
test machine with this series please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
