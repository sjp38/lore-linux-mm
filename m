Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBENTfFJ683822
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 18:29:41 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBENTfYB334344
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 16:29:41 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBENTfFO031475
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 16:29:41 -0700
Date: Tue, 14 Dec 2004 14:00:28 -0800
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <50260000.1103061628@flay>
In-Reply-To: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com><9250000.1103050790@flay> <20041214191348.GA27225@wotan.suse.de><19030000.1103054924@flay> <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> > I originally was a bit worried about the TLB usage, but it doesn't
>> > seem to be a too big issue (hopefully the benchmarks weren't too
>> > micro though)
>> 
>> Well, as long as we stripe on large page boundaries, it should be fine,
>> I'd think. On PPC64, it'll screw the SLB, but ... tough ;-) We can either
>> turn it off, or only do it on things larger than the segment size, and
>> just round-robin the rest, or allocate from node with most free.
> 
> Is there a reasonably easy-to-use existing infrastructure to do this?
> I didn't find anything in my examination of vmalloc itself, so I gave
> up on the idea.

Not that I know of. But (without looking at it), it wouldn't seem 
desperately hard to implement (some argument or flag to vmalloc, or vmalloc_largepage) or something.

> And just to clarify, are you saying you want to see this before inclusion
> in mainline kernels, or that it would be nice to have but not necessary?

I'd say it's a nice to have, rather than necessary, as long as it's not
forced upon people. Maybe a config option that's on by default on ia64
or something. Causing yourself TLB problems is much more acceptable than
causing it for others ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
