Date: Sat, 31 Dec 2005 00:24:38 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
In-Reply-To: <20051231032702.GA9136@dmt.cnet>
Message-ID: <Pine.LNX.4.63.0512302321420.16308@cuia.boston.redhat.com>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
 <20051230224312.765.58575.sendpatchset@twins.localnet> <20051231002417.GA4913@dmt.cnet>
 <Pine.LNX.4.63.0512302019530.2845@cuia.boston.redhat.com> <20051231032702.GA9136@dmt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>
List-ID: <linux-mm.kvack.org>

On Sat, 31 Dec 2005, Marcelo Tosatti wrote:

> I meant something more like Documentation/vm/clockpro.txt, for easier
> reading of patch reviewers and community in general. 

Agreed.

> > > Why do you use only two clock hands and not three (HandHot, HandCold and 
> > > HandTest) as in the original paper?
> > 
> > Because the non-resident pages cannot be in the clock.
> > This is both because of space overhead, and because the
> > non-resident list cannot be per zone.
> 
> I see - that is a fundamental change from the original CLOCK-Pro
> algorithm, right? 
> 
> Do you have a clear idea about the consequences of not having           
> non-resident pages in the clock? 

The consequence is that we could falsely consider a non-resident
page to be active, or not to be active.  However, this can only
happen if we let the scan rate in each of the memory zones get
way too much out of whack (which is bad regardless).

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
