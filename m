Message-ID: <4366AFC7.3060505@yahoo.com.au>
Date: Tue, 01 Nov 2005 10:59:03 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <20051030183354.22266.42795.sendpatchset@skynet.csn.ul.ie><20051031055725.GA3820@w-mikek2.ibm.com><4365BBC4.2090906@yahoo.com.au><20051030235440.6938a0e9.akpm@osdl.org><27700000.1130769270@[10.10.2.4]> <20051031112409.153e7048.akpm@osdl.org> <3660000.1130787652@flay>
In-Reply-To: <3660000.1130787652@flay>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
> --On Monday, October 31, 2005 11:24:09 -0800 Andrew Morton <akpm@osdl.org> wrote:

>>I suspect this would all be a non-issue if the net drivers were using
>>__GFP_NOWARN ;)
> 
> 
> We still need to allocate them, even if it's GFP_KERNEL. As memory gets
> larger and larger, and we have no targetted reclaim, we'll have to blow
> away more and more stuff at random before we happen to get contiguous
> free areas. Just statistics aren't in your favour ... Getting 4 contig
> pages on a 1GB desktop is much harder than on a 128MB machine. 
> 

However, these allocations are not of the "easy to reclaim" type, in
which case they just use the regular fragmented-to-shit areas. If no
contiguous pages are available from there, then an easy-reclaim area
needs to be stolen, right?

In which case I don't see why these patches don't have similar long
term failure cases if there is strong demand for higher order
allocations. Prolong things a bit, perhaps, but...

> Is not going to get better as time goes on ;-) Yeah, yeah, I know, you
> want recreates, numbers, etc. Not the easiest thing to reproduce in a
> short-term consistent manner though.
> 

Regardless, I think we need to continue our steady move away from
higher order allocation requirements.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
