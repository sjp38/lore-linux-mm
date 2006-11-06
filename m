Date: Mon, 6 Nov 2006 09:26:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <200611061820.01943.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0611060923480.25683@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <200611061807.16890.ak@suse.de> <Pine.LNX.4.64.0611060912070.25496@schroedinger.engr.sgi.com>
 <200611061820.01943.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Nov 2006, Andi Kleen wrote:

> From my previous slab experiences I predict it will not work anymore in less than
> half a year. Such fragile constructions never tend to hold long.

This has been around for quite some time. The signalhand cache uses the 
same method.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
