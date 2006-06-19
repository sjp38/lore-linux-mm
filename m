Date: Mon, 19 Jun 2006 08:45:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] inactive_clean
In-Reply-To: <1150719606.28517.83.camel@lappy>
Message-ID: <Pine.LNX.4.64.0606190837450.1184@schroedinger.engr.sgi.com>
References: <1150719606.28517.83.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, Nick Piggin <piggin@cyberone.com.au>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2006, Peter Zijlstra wrote:

> My previous efforts at tracking dirty pages focused on shared pages.
> But shared pages are not all and, quite often even a small part of the
> problem. Most 'normal' workloads are dominated by anonymous pages.

Shared pages are the major problem because we have no way of tracking 
their dirty state. Shared file mapped pages are a problem because they require 
writeout which will not occur if we are not aware of them. The dirty state 
of anonymous pages typically does not matter because these pages are 
thrown away when a process terminates.

> So, in order to guarantee easily freeable pages we also have to look
> at anonymous memory. Thinking about it I arrived at something Rik
> invented long ago: the inactive_clean list - a third LRU list consisting
> of clean pages.

I fail to see the point. What is the problem with anonymous memory? Swap?

> The thing I like least about the current impl. is that all clean pages
> are unmapped; I'd like to have them mapped but read-only and trap the
> write faults (next step?).

This is some sort of swap problem?

> Also, setting the clean watermarks needs more thought.
> 
> Comments?

I am not clear what issue you are trying to solve. Seem that this is 
something entirely different. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
