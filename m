Message-ID: <43E0842A.105@yahoo.com.au>
Date: Wed, 01 Feb 2006 20:49:30 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] Shared page tables
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]> <200601240210.04337.ak@suse.de> <1138086398.2977.19.camel@laptopd505.fenrus.org> <200601240818.28696.ak@suse.de>
In-Reply-To: <200601240818.28696.ak@suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Arjan van de Ven <arjan@infradead.org>, Ray Bryant <raybry@mpdtxmail.amd.com>, Dave McCracken <dmccr@us.ibm.com>, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> 
> Well, we first have to figure out if the shared page tables
> are really worth all the ugly code, nasty locking and other problems 
> (inefficient TLB flush etc.) I personally would prefer
> to make large pages work better before going down that path.
> 

Other thing I wonder about - less efficient page table placement
on NUMA systems might harm TLB miss latency on some systems
(although we don't always do a great job of trying to localise these
things yet anyway). Another is possible increased lock contention on
widely shared page tables like libc.

I agree that it is not something which needs to be rushed in any
time soon. We've already got significant concessions and complexity
in the memory manager for databases (hugepages, direct io / raw io)
so a few % improvement on database performance doesn't put it on our
must have list IMO.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
