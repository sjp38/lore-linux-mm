Date: Tue, 3 Jan 2006 11:08:14 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] Event counters [1/3]: Basic counter functionality
In-Reply-To: <43B63931.6000307@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0601031102560.20946@schroedinger.engr.sgi.com>
References: <20051220235733.30925.55642.sendpatchset@schroedinger.engr.sgi.com>
 <20051231064615.GB11069@dmt.cnet> <43B63931.6000307@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, 31 Dec 2005, Nick Piggin wrote:

> So I'm not exactly sure why such a patch as this is wanted now? Are there
> any more xxx_page_state hotspots? (I admit to only looking at page faults,
> page allocator, and page reclaim).

The proposed patchset is based on the zoned counter patchset. This means 
that critical counters have been converted to use different macros. The 
following discussion of Marcelo and Nick on nr_mapped etc is not relevant 
to this patch since nr_mapped etc are not event counters but are handled 
by the zoned counters.

The event counters are the leftover vanity counters that are referenced 
only for display in /proc and the proposed approach is to only allow 
increments and allow racy updates.

Then these lightweight counters are also used to optimize away the numa 
specific counters in the per cpu structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
