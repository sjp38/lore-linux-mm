Date: Fri, 10 Jun 2005 09:20:00 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
In-Reply-To: <537960000.1118251081@[10.10.2.4]>
Message-ID: <Pine.LNX.4.62.0506100918460.10707@graphe.net>
References: <20050531112048.D2511E57A@skynet.csn.ul.ie>
 <429E20B6.2000907@austin.ibm.com><429E4023.2010308@yahoo.com.au>
 <423970000.1117668514@flay><429E483D.8010106@yahoo.com.au>
 <434510000.1117670555@flay><429E50B8.1060405@yahoo.com.au>
 <429F2B26.9070509@austin.ibm.com><1117770488.5084.25.camel@npiggin-nld.site><Pine.LNX.4.58.0506031349280.10779@skynet>
 <370550000.1117807258@[10.10.2.4]> <Pine.LNX.4.58.0506081734480.10706@skynet>
 <537960000.1118251081@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, jschopp@austin.ibm.com, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jun 2005, Martin J. Bligh wrote:

> Right. I agree that large allocs should be reliable. Whether we care so
> much about if they're performant or not, I don't know ... is an interesting
> question. I think the answer is maybe not, within reason. The cost of
> fishing in the allocator might well be irrelevant compared to the cost
> of freeing the necessary memory area?

Large consecutive page allocation is important for I/O. Lots of drivers 
are able to issue transfer requests spanning multiple pages which is only 
possible if the pages are in sequence. If memory is fragmented then this 
is no longer possible.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
