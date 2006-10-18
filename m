Message-ID: <45363E66.8010201@google.com>
Date: Wed, 18 Oct 2006 07:47:02 -0700
From: "Martin J. Bligh" <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [RFC] Remove temp_priority
References: <45351423.70804@google.com> <4535160E.2010908@yahoo.com.au> <45351877.9030107@google.com> <45362130.6020804@yahoo.com.au>
In-Reply-To: <45362130.6020804@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> Coming from another angle, I am thinking about doing away with direct
> reclaim completely. That means we don't need any GFP_IO or GFP_FS, and
> solves the problem of large numbers of processes stuck in reclaim and
> skewing aging and depleting the memory reserve.

Last time I proposed that, the objection was how to throttle the heavy
dirtiers so they don't fill up RAM with dirty pages?

Also, how do you do atomic allocations? Create a huge memory pool and
pray really hard?

> But that's tricky because we don't have enough kswapds to get maximum
> reclaim throughput on many configurations (only single core opterons
> and UP systems, really).

It's not a question of enough kswapds. It's that we can dirty pages
faster than they can possibly be written to disk.

dd if=/dev/zero of=/tmp/foo

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
