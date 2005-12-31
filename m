Date: Sat, 31 Dec 2005 01:27:02 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
Message-ID: <20051231032702.GA9136@dmt.cnet>
References: <20051230223952.765.21096.sendpatchset@twins.localnet> <20051230224312.765.58575.sendpatchset@twins.localnet> <20051231002417.GA4913@dmt.cnet> <Pine.LNX.4.63.0512302019530.2845@cuia.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.63.0512302019530.2845@cuia.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>
List-ID: <linux-mm.kvack.org>

Hi Rik!

On Fri, Dec 30, 2005 at 08:22:12PM -0500, Rik van Riel wrote:
> On Fri, 30 Dec 2005, Marcelo Tosatti wrote:
> 
> > I think that final objective should be to abstract it away completly,
> > making it possible to select between different policies, allowing
> > further experimentation and implementations such as energy efficient
> > algorithms.
> 
> I'm not convinced.  That might just make vmscan.c harder to read ;)

Are you serious or just joking? :) 

Sure it might make it harder to read, but allowing selectable policies
is very interesting. Peter's patches go half-way into that direction.

Lets say, if CLOCK-Pro underperforms for a given workload (take into
account that its simply optimizing reclaim for a subset of all existing
access patterns, ie. heuristics), it would be easier for people to
develop/use different policies.

> > About CLOCK-Pro itself, I think that a small document with a short
> > introduction would be very useful...
> 
> http://linux-mm.org/AdvancedPageReplacement

I meant something more like Documentation/vm/clockpro.txt, for easier
reading of patch reviewers and community in general. 

> > > The HandCold rotation is driven by page reclaim needs. HandCold in turn
> > > drives HandHot, for every page HandCold promotes to hot HandHot needs to
> > > degrade one hot page to cold.
> > 
> > Why do you use only two clock hands and not three (HandHot, HandCold and 
> > HandTest) as in the original paper?
> 
> Because the non-resident pages cannot be in the clock.
> This is both because of space overhead, and because the
> non-resident list cannot be per zone.

I see - that is a fundamental change from the original CLOCK-Pro
algorithm, right? 

Do you have a clear idea about the consequences of not having           
non-resident pages in the clock? 

> I agree though, Peter's patch could use a lot more
> documentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
