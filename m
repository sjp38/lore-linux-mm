Date: Tue, 18 Jul 2006 08:57:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: inactive-clean list
In-Reply-To: <44BCFA4D.9030300@mbligh.org>
Message-ID: <Pine.LNX.4.64.0607180855090.31431@schroedinger.engr.sgi.com>
References: <1153167857.31891.78.camel@lappy>
 <Pine.LNX.4.64.0607172035140.28956@schroedinger.engr.sgi.com>
 <1153224998.2041.15.camel@lappy> <Pine.LNX.4.64.0607180557440.30245@schroedinger.engr.sgi.com>
 <44BCE86A.4030602@mbligh.org> <Pine.LNX.4.64.0607180657160.30887@schroedinger.engr.sgi.com>
 <44BCFA4D.9030300@mbligh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jul 2006, Martin J. Bligh wrote:
> > Maybe we need a NR_UNSTABLE that includes pinned pages?
> 
> The point of what we decided on Sunday was that we want to count the
> pages that we KNOW are easy to free. So all of these should be
> taken out of the count before we take it.

Unmapped clean pages are easily freeable and do not have these issues.
Could we just use that for now? Otherwise we have to add counters to the 
categories that we do not track for now and take them out of the count.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
