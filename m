Subject: Re: [PATCH 2.5.43-mm2] New shared page table patch
References: <Pine.LNX.3.96.1021019151523.29078E-200000@gatekeeper.tmr.com>
	<2458064740.1035069495@[10.10.2.3]>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 21 Oct 2002 08:55:24 -0600
In-Reply-To: <2458064740.1035069495@[10.10.2.3]>
Message-ID: <m1bs5nvo2r.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Bill Davidsen <davidsen@tmr.com>, Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> writes:

> >> For reference, one of the tests was TPC-H.  My code reduced the number of
> >> allocated pte_chains from 5 million to 50 thousand.
> > 
> > Don't tease, what did that do for performance? I see that someone has
> > already posted a possible problem, and the code would pass for complex for
> > most people, so is the gain worth the pain?
> 
> In many cases, this will stop the box from falling over flat on it's 
> face due to ZONE_NORMAL exhaustion (from pte-chains), or even total
> RAM exhaustion (from PTEs). Thus the performance gain is infinite ;-)

So why has no one written a pte_chain reaper?  It is perfectly sane
to allocate a swap entry and move an entire pte_chain to the swap
cache.  

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
