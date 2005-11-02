Date: Wed, 02 Nov 2005 06:51:37 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <253150000.1130943095@[10.10.2.4]>
In-Reply-To: <43687C3D.7060706@yahoo.com.au>
References: <1130917338.14475.133.camel@localhost> <436877DB.7020808@yahoo.com.au> <20051102172729.9E7C.Y-GOTO@jp.fujitsu.com> <43687C3D.7060706@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> Well I think it can satisfy hugepage allocations simply because
> we can be reasonably sure of being able to free contiguous regions.
> Of course it will be memory no longer easily reclaimable, same as
> the case for the frag patches. Nor would be name ZONE_REMOVABLE any
> longer be the most appropriate!
> 
> But my point is, the basic mechanism is there and is workable.
> Hugepages and memory unplug are the two main reasons for IBM to be
> pushing this AFAIKS.

No, that's not true - those are just the "exciting" features that go 
on the back of it. Look back in this email thread - there's lots of
other reasons to fix fragmentation. I don't believe you can eliminate
all the order > 0 allocations in the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
