Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
	a second trip around the LRU
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20070525014301.ed817a91.akpm@linux-foundation.org>
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
	 <1180076565.7348.14.camel@twins>
	 <20070525001812.9dfc972e.akpm@linux-foundation.org>
	 <1180077810.7348.20.camel@twins>
	 <20070525002829.19deb888.akpm@linux-foundation.org>
	 <1180078590.7348.27.camel@twins>
	 <20070525004808.84ae5cf3.akpm@linux-foundation.org>
	 <1180079479.7348.33.camel@twins>
	 <20070525010112.2c5754ac.akpm@linux-foundation.org>
	 <1180082124.7348.55.camel@twins>
	 <20070525014301.ed817a91.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 25 May 2007 12:13:08 +0200
Message-Id: <1180087988.7348.59.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-25 at 01:43 -0700, Andrew Morton wrote:

> Well yeah.  I look at this patch and I can say with confidence that it will
> increase our tendency to swap and that it'll cause reclaim to scan more
> pages and that it'll increase the ease with which we declare oom.
> 
> otoh it takes us closer to the designed 4-stage page aging.  But does it
> actually make the kernel better?  Unknown and unknowable.

Ah, here I see my mistake and your confusion; I actually thought the
design mattered :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
