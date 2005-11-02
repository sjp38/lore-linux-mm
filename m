Date: Wed, 02 Nov 2005 06:57:01 -0800
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <253790000.1130943420@[10.10.2.4]>
In-Reply-To: <20051102084946.GA3930@elte.hu>
References: <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu> <1130856555.14475.77.camel@localhost> <20051101150142.GA10636@elte.hu> <1130858580.14475.98.camel@localhost> <20051102084946.GA3930@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Dave Hansen <haveblue@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

> reliable hot-remove of generic kernel RAM is plain impossible even in a 
> fully virtualized solution. It's impossible even with maximum hardware 
> help. We simply dont have the means to fix up live kernel pointers still 
> linked into the removed region, under the C programming model.
> 
> the hurdles towards a reliable solution are so incredibly high, that
> other solutions _have_ to be considered: restrict the type of RAM that
> can be removed, and put it into a separate zone. That solves things
> easily: no kernel pointers will be allowed in those zones. It becomes
> similar to highmem: various kernel caches can opt-in to be included in
> that type of RAM, and the complexity (and maintainance impact) of the
> approach can thus be nicely scaled.

Forget about freeing up arbitrary regions of RAM. I don't think anyone has
strong enough drugs to seriously believe that works in the generic case.
What we need is to free a small region of RAM, that's contiguous. Larger
than one page, likely a few MB. Exactly WHICH region is pretty irrelevant,
since mostly we just want one contiguous chunk to use. 

Hypervisors do not remap at page-level granularity - that seems to be
the source of some of the confusion here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
