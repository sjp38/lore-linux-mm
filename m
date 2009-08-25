Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 588326B008A
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 15:43:38 -0400 (EDT)
Received: by pzk36 with SMTP id 36so1812661pzk.12
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 12:43:11 -0700 (PDT)
Message-ID: <4A94293A.2090103@vflare.org>
Date: Tue, 25 Aug 2009 23:41:06 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] compcache: documentation
References: <200908241008.02184.ngupta@vflare.org> <661de9470908251003y3db1fb3awb648f9340cd0beb4@mail.gmail.com>
In-Reply-To: <661de9470908251003y3db1fb3awb648f9340cd0beb4@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On 08/25/2009 10:33 PM, Balbir Singh wrote:


>> +It consists of three modules:
>> + - xvmalloc.ko: memory allocator
>
> I've seen your case for a custom allocator, but why can't we
>
> 1) Refactor slob and use it

SLOB is fundamentally a different allocator. It looked at it in detail
but could not image how can I make it suitable for the project. SLOB
really does not fit it.

> 2) Do we care about the optimizations in SLUB w.r.t. scalability in
> your module? If so.. will xvmalloc meet those requirements?
>

Scalability is desired which xvmalloc lacks in its current state. My
plan is to have a wrapper around xvmalloc that creates per-cpu pools
and leave xvmalloc core simple. Along with this, detailed profiling
needs to be done to see where the bottlenecks are in the core itself.


>
> What level of compression have you observed? Any speed trade-offs?
>

All the performance numbers can be found at:
http://code.google.com/p/compcache/wiki/Performance

I also summarized these in patch [0/4]:
http://lkml.org/lkml/2009/8/24/8

The compression ratio is highly workload dependent. On "generic" desktop
workload, stats show:
  - ~80% of pages compressing to PAGE_SIZE/2 or less.
  - ~1% incompressible pages.


For the speed part, please refer to performance numbers at link above.
It show cases where it help or hurts the performance.

Thanks,
Nitin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
