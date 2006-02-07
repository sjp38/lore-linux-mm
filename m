From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] mm: implement swap prefetching
Date: Tue, 7 Feb 2006 23:39:08 +0100
References: <200602071028.30721.kernel@kolivas.org> <43E8436F.2010909@yahoo.com.au> <20060207203420.GA10493@dmt.cnet>
In-Reply-To: <20060207203420.GA10493@dmt.cnet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602072339.09327.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 February 2006 21:34, Marcelo Tosatti wrote:
> On Tue, Feb 07, 2006 at 05:51:27PM +1100, Nick Piggin wrote:
> > Con Kolivas wrote:
> > >On Tue, 7 Feb 2006 04:00 pm, Nick Piggin wrote:
> > >
> > >>Con Kolivas wrote:
> > >>
> > >>>On Tue, 7 Feb 2006 02:08 pm, Nick Piggin wrote:
> > >>>
> > >>>>prefetch_get_page is doing funny things with zones and nodes / zonelists
> > >>>>(eg. 'We don't prefetch into DMA' meaning something like 'this only 
> > >>>>works
> > >>>>on i386 and x86-64').
> > >>>
> > >>>Hrm? It's just a generic thing to do; I'm not sure I follow why it's i386
> > >>>and x86-64 only. Every architecture has ZONE_NORMAL so it will prefetch
> > >>>there.
> > >>
> > >>I don't think every architecture has ZONE_NORMAL.
> > >
> > >
> > >!ZONE_DMA they all have, no?
> > >
> > 
> > Don't think so. IIRC ppc64 has only ZONE_DMA although may have picked up
> > DMA32 now (/me boots the G5). IA64 I think have 4GB ZONE_DMA so smaller
> > systems won't have any other zones.
> > 
> > On small memory systems, ZONE_DMA will be a significant portion of memory
> > too (but maybe you're not targetting them either).
> 
> embedded 32-bit PPC's have all their memory in DMA:

Most x86-64 systems have their memory in ZONE_DMA32 now. Only large ones
have any ZONE_NORMAL >4GB. So it's not even true on x86-64 :)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
