Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E1C236B01F9
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 14:48:32 -0400 (EDT)
Message-ID: <4BBB81BB.9080206@redhat.com>
Date: Tue, 06 Apr 2010 21:47:23 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> <4BBB052D.8040307@redhat.com> <4BBB2134.9090301@redhat.com> <20100406131024.GA5288@laptop> <4BBB359D.1020603@redhat.com> <20100406134539.GC5288@laptop>
In-Reply-To: <20100406134539.GC5288@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/06/2010 04:45 PM, Nick Piggin wrote:
>
>>   I don't see how
>> hardware improvements can drastically change the numbers above, it's
>> clear that for the 4k case the host takes a cache miss for the pte,
>> and twice for the 4k/4k guest case.
>>      
> It's because you're missing the point. You're taking the most
> unrealistic and pessimal cases and then showing that it has fundamental
> problems. Speedups like Linus is talking about would refer to ways to
> speed up actual workloads, not ways to avoid fundamental limitations.
>
> Prefetching, memory parallelism, caches. It's worked for 25 years :)
>    

btw, a workload that's known to benefit greatly from large pages is the 
kernel itself.  It's very pointer-chasey and has a large working set 
(the whole of memory, in fact).  But once you run it in a guest you've 
turned it into the 2M/4k case in the table which is basically a slightly 
slower version of host 4k pages.

So, if we want good support for kernel intensive workloads in guests, or 
kernel-like workloads in the host (or kernel-like workloads in guest 
userspace), then we need good large page support.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
