Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 679CA6B003D
	for <linux-mm@kvack.org>; Thu, 19 Feb 2009 07:51:50 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so213176waf.22
        for <linux-mm@kvack.org>; Thu, 19 Feb 2009 04:51:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1235034967.29813.10.camel@penberg-laptop>
References: <20090218093858.8990.A69D9226@jp.fujitsu.com>
	 <1234944569.24030.20.camel@penberg-laptop>
	 <20090219085229.954A.A69D9226@jp.fujitsu.com>
	 <1235034967.29813.10.camel@penberg-laptop>
Date: Thu, 19 Feb 2009 21:51:48 +0900
Message-ID: <2f11576a0902190451w294aa2fan29b61fa3619f459b@mail.gmail.com>
Subject: Re: [patch] SLQB slab allocator (try 2)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

2009/2/19 Pekka Enberg <penberg@cs.helsinki.fi>:
> On Wed, 2009-02-18 at 09:48 +0900, KOSAKI Motohiro wrote:
>> > > In addition, if pekka patch (SLAB_LIMIT = 8K) run on ia64, 16K allocation
>> > > always fallback to page allocator and using 64K (4 times memory consumption!).
>> >
>> > Yes, correct, but SLUB does that already by passing all allocations over
>> > 4K to the page allocator.
>>
>> hmhm
>> OK. my mail was pointless.
>>
>> but why? In my understanding, slab framework mainly exist for efficient
>> sub-page allocation.
>> the fallbacking of 4K allocation in 64K page-sized architecture seems
>> inefficient.
>
> I don't think any of the slab allocators are known for memory
> efficiency. That said, the original patch description sums up the
> rationale for page allocator pass-through:
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=aadb4bc4a1f9108c1d0fbd121827c936c2ed4217
>
> Interesting enough, there seems to be some performance gain from it as
> well as seen by Mel Gorman's recent slab allocator benchmarks.

Honestly, I'm bit confusing.
above url's patch use PAGE_SIZE, but not 4K nor architecture independent value.
Your 4K mean PAGE_SIZE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
