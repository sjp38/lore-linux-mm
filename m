Date: Mon, 4 Feb 2008 16:32:50 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [git pull] SLUB updates for 2.6.25
In-Reply-To: <200802051105.12194.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0802041629290.5057@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802041206190.3241@schroedinger.engr.sgi.com>
 <200802051010.49372.nickpiggin@yahoo.com.au>
 <Pine.LNX.4.64.0802041542570.4774@schroedinger.engr.sgi.com>
 <200802051105.12194.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Feb 2008, Nick Piggin wrote:

> Ok. But the approach is just not so good. If you _really_ need something
> like that and it is a win over the regular non-atomic unlock, then you
> just have to implement it as a generic locking / atomic operation and
> allow all architectures to implement the optimal (and correct) memory
> barriers.

Assuming this really gives a benefit on several benchmarks then we need 
to think about how to do this some more. Its a rather strange form of 
locking.
 
Basically you lock the page with a single atomic operation that sets 
PageLocked and retrieves the page flags. Then we shovel the page state 
around a couple of functions in a register and finally store the page 
state back which at the same time unlocks the page. So two memory 
references with one of them being atomic with none in between. We have 
nothing that can do something like that right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
