Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C7B116B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 09:12:09 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 5 Aug 2013 23:04:01 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id BE3972BB0055
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 23:12:05 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r75Cu99v5505150
	for <linux-mm@kvack.org>; Mon, 5 Aug 2013 22:56:18 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r75DBtiP014325
	for <linux-mm@kvack.org>; Mon, 5 Aug 2013 23:11:56 +1000
Date: Mon, 5 Aug 2013 21:11:53 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130805130919.GA7104@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <20130805103456.GB1039@hacker.(null)>
 <20130805113423.GB6703@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130805113423.GB6703@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 05, 2013 at 01:34:23PM +0200, Andrea Arcangeli wrote:
>On Mon, Aug 05, 2013 at 06:34:56PM +0800, Wanpeng Li wrote:
>> Why round robin allocator don't consume ZONE_DMA?
>
>I guess lowmem reserve reserves it all, 4GB/256(ratio)=16MB.
>

Ah, lowmem reservation reserve all ZONE_DMA:

x86_64 4GB

protection: (0, 3251, 4009, 4009)

Thanks for pointing out. ;-)

>The only way to relax it would be 1) to account depending on memblock
>types and allow only the movable ones to bypass the lowmem reserve and
>prevent a change from movable type if lowmem reserve doesn't pass, 2)
>use memory migration to move the movable pages from the lower zones to
>the highest zone if reclaim fails if __GFP_DMA32 or __GFP_DMA is set,
>or highmem is missing on 32bit kernels. The last point involving
>memory migration would work similarly to compaction but it isn't black
>and white, and it would cost CPU as well. The memory used by the
>simple lowmem reserve mechanism is probably not significant enough to
>warrant such an effort.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
