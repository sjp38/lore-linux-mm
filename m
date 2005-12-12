Date: Mon, 12 Dec 2005 04:56:32 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 1/6] Framework
Message-ID: <20051212035631.GX11190@wotan.suse.de>
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005445.3887.94119.sendpatchset@schroedinger.engr.sgi.com> <439CF2A2.60105@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <439CF2A2.60105@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 12, 2005 at 02:46:42PM +1100, Nick Piggin wrote:
> Christoph Lameter wrote:
> 
> >+/*
> >+ * For use when we know that interrupts are disabled.
> >+ */
> >+static inline void __mod_zone_page_state(struct zone *zone, enum 
> >zone_stat_item item, int delta)
> >+{
> 
> Before this goes through, I have a full patch to do similar for the
> rest of the statistics, and which will make names consistent with what
> you have (shouldn't be a lot of clashes though).

I also have a patch to change them all to local_t, greatly simplifying
it (e.g. the counters can be done inline then) 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
