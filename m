Date: Tue, 7 Feb 2006 14:34:20 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] mm: implement swap prefetching
Message-ID: <20060207203420.GA10493@dmt.cnet>
References: <200602071028.30721.kernel@kolivas.org> <200602071502.41456.kernel@kolivas.org> <43E82979.7040501@yahoo.com.au> <200602071702.20233.kernel@kolivas.org> <43E8436F.2010909@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43E8436F.2010909@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 07, 2006 at 05:51:27PM +1100, Nick Piggin wrote:
> Con Kolivas wrote:
> >On Tue, 7 Feb 2006 04:00 pm, Nick Piggin wrote:
> >
> >>Con Kolivas wrote:
> >>
> >>>On Tue, 7 Feb 2006 02:08 pm, Nick Piggin wrote:
> >>>
> >>>>prefetch_get_page is doing funny things with zones and nodes / zonelists
> >>>>(eg. 'We don't prefetch into DMA' meaning something like 'this only 
> >>>>works
> >>>>on i386 and x86-64').
> >>>
> >>>Hrm? It's just a generic thing to do; I'm not sure I follow why it's i386
> >>>and x86-64 only. Every architecture has ZONE_NORMAL so it will prefetch
> >>>there.
> >>
> >>I don't think every architecture has ZONE_NORMAL.
> >
> >
> >!ZONE_DMA they all have, no?
> >
> 
> Don't think so. IIRC ppc64 has only ZONE_DMA although may have picked up
> DMA32 now (/me boots the G5). IA64 I think have 4GB ZONE_DMA so smaller
> systems won't have any other zones.
> 
> On small memory systems, ZONE_DMA will be a significant portion of memory
> too (but maybe you're not targetting them either).

embedded 32-bit PPC's have all their memory in DMA:

Free pages:      186376kB (0kB HighMem)
Active:3095 inactive:13281 dirty:0 writeback:0 unstable:0 free:46594 slab:928 mapped:2471 pagetables:80
DMA free:186376kB min:2048kB low:2560kB high:3072kB active:12380kB inactive:53124kB present:262144kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Normal free:0kB min:0kB low:0kB high:0kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
HighMem free:0kB min:128kB low:160kB high:192kB active:0kB inactive:0kB present:0kB pages_scanned:0 all_unreclaimable? no



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
