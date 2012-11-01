Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 9CB336B0044
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 09:14:09 -0400 (EDT)
Message-ID: <5092758C.10309@redhat.com>
Date: Thu, 01 Nov 2012 09:13:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/31] sched, numa, mm: Describe the NUMA scheduling problem
 formally
References: <20121025121617.617683848@chello.nl> <20121025124832.621452204@chello.nl> <20121101095658.GM3888@suse.de>
In-Reply-To: <20121101095658.GM3888@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "H. Peter Anvin" <hpa@zytor.com>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@kernel.org>

On 11/01/2012 05:56 AM, Mel Gorman wrote:
> On Thu, Oct 25, 2012 at 02:16:19PM +0200, Peter Zijlstra wrote:
>> This is probably a first: formal description of a complex high-level
>> computing problem, within the kernel source.
>>
>
> Who does not love the smell of formal methods first thing in the
> morning?

The only issue I have with this document is that it does not have
any description of how the source code tries to solve the problem
at hand.

A description of how the problem is solved will make the documentation
useful to people trying to figure out why the NUMA code does what
it does.

Of course, since we still do not know what sched-numa needs to do
in order to match autonuma performance, that description would have
to be updated later, anyway.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
