Date: Fri, 30 Dec 2005 20:22:12 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
In-Reply-To: <20051231002417.GA4913@dmt.cnet>
Message-ID: <Pine.LNX.4.63.0512302019530.2845@cuia.boston.redhat.com>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
 <20051230224312.765.58575.sendpatchset@twins.localnet> <20051231002417.GA4913@dmt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Dec 2005, Marcelo Tosatti wrote:

> I think that final objective should be to abstract it away completly,
> making it possible to select between different policies, allowing
> further experimentation and implementations such as energy efficient
> algorithms.

I'm not convinced.  That might just make vmscan.c harder to read ;)

> About CLOCK-Pro itself, I think that a small document with a short
> introduction would be very useful...

http://linux-mm.org/AdvancedPageReplacement

> > The HandCold rotation is driven by page reclaim needs. HandCold in turn
> > drives HandHot, for every page HandCold promotes to hot HandHot needs to
> > degrade one hot page to cold.
> 
> Why do you use only two clock hands and not three (HandHot, HandCold and 
> HandTest) as in the original paper?

Because the non-resident pages cannot be in the clock.
This is both because of space overhead, and because the
non-resident list cannot be per zone.

I agree though, Peter's patch could use a lot more
documentation.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
