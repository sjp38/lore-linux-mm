Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 88C766B00AD
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 09:32:37 -0500 (EST)
Date: Mon, 23 Feb 2009 14:32:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
Message-ID: <20090223143232.GJ6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <87ljryuij0.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87ljryuij0.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 01:02:59AM +0100, Andi Kleen wrote:
> Mel Gorman <mel@csn.ul.ie> writes:
> 
> 
> BTW one additional tuning opportunity would be to change cpusets to
> always precompute zonelists out of line and then avoid doing
> all these checks in the fast path.
> 

hmm, it would be ideal but I haven't looked too closely at how it could
be implemented. I thought first you could just associate a zonelist with
the cpuset but you'd need one for each node allowed by the cpuset so it
could get quite large. Then again, it might be worthwhile if cpusets
were expected to be very long lived.

If there are any users of cpusets watching, would you be interested in
profiling with cpusets enabled and see how much time we spend in that
code?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
