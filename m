Date: Fri, 25 May 2007 01:43:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
 a second trip around the LRU
Message-Id: <20070525014301.ed817a91.akpm@linux-foundation.org>
In-Reply-To: <1180082124.7348.55.camel@twins>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007 10:35:24 +0200 Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, 2007-05-25 at 01:01 -0700, Andrew Morton wrote:
> > On Fri, 25 May 2007 09:51:19 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > 
> > But why?  It might make the VM suck.  Or swap more.  Or go oom.
> > 
> > I don't know how to justify merging this.
> 
> /me a tad confused here - what patch are we discussing?
> The ACK was for your initial patch.

Yup, that patch.

> As for my patch - yes I understand that that would be difficult, but
> sometimes you seem to just toss things in to see how they work out (one
> can always hope, right :-)
> 
> As for the rationale: not clearing the referenced state when we do give
> the page another go on the active list, means it will get yet another
> one when we finally do check it (and reclaim_mapped is deemed ok).
> 
> Not doing it basically gives all those pages another go after
> reclaim_mapped is set.
> 
> I realise this is not backed up by evidence of actual tests,.. :-(

Well yeah.  I look at this patch and I can say with confidence that it will
increase our tendency to swap and that it'll cause reclaim to scan more
pages and that it'll increase the ease with which we declare oom.

otoh it takes us closer to the designed 4-stage page aging.  But does it
actually make the kernel better?  Unknown and unknowable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
