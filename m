Date: Tue, 12 Feb 2008 12:10:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Fastpath prototype?
In-Reply-To: <200802121140.12040.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0802121208150.2120@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080211235607.GA27320@wotan.suse.de> <Pine.LNX.4.64.0802112205150.26977@schroedinger.engr.sgi.com>
 <200802121140.12040.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Andi Kleen wrote:

> But if you add another fast path you should first remove the old one 
> at least.

Definitely thinking about that. We could just drop the pcp stuff. The 
current page allocator "fastpath" causes a 5% regression on my in kernel 
page allocator benchmarks and also on Mel's tests. The current pcp 
page queuing is mainly useful to hold off zone lock contention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
