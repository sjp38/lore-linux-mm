Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4159C6B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 01:19:44 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so829597pdi.19
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 22:19:43 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id do3si13228819pbc.352.2013.11.21.22.19.42
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 22:19:42 -0800 (PST)
Message-ID: <528EF744.8040607@intel.com>
Date: Thu, 21 Nov 2013 22:18:44 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: NUMA? bisected performance regression 3.11->3.12
References: <528E8FCE.1000707@intel.com> <20131122052219.GL3556@cmpxchg.org>
In-Reply-To: <20131122052219.GL3556@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kevin Hilman <khilman@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Paul Bolle <paul.bollee@gmail.com>, Zlatko Calusic <zcalusic@bitsync.net>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>

On 11/21/2013 09:22 PM, Johannes Weiner wrote:
>> > It's a 8-socket/160-thread (one NUMA node per socket) system that is not
>> > under memory pressure during the test.  The latencies are also such that
>> > vm.zone_reclaim_mode=0.
> The change will definitely spread allocations out to all nodes then
> and it's plausible that the remote references will hurt kernel object
> allocations in a tight loop.  Just to confirm, could you rerun the
> test with zone_reclaim_mode enabled to make the allocator stay in the
> local zones?

Yeah, setting vm.zone_reclaim_mode=1 fixes it pretty instantaneously.

For what it's worth, I'm pretty convinced that the numbers folks put in
the SLIT tables are, at best, horribly inconsistent from system to
system.  At worst, they're utter fabrications not linked at all to the
reality of the actual latencies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
