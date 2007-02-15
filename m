Date: Thu, 15 Feb 2007 08:05:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/7] Add PageMlocked() page state bit and lru infrastructure
In-Reply-To: <45D48075.8000709@mbligh.org>
Message-ID: <Pine.LNX.4.64.0702150801160.10837@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
 <20070215012459.5343.72021.sendpatchset@schroedinger.engr.sgi.com>
 <20070215020916.GS10108@waste.org> <Pine.LNX.4.64.0702141829410.5747@schroedinger.engr.sgi.com>
 <20070215145138.GT10108@waste.org> <Pine.LNX.4.64.0702150722580.10403@schroedinger.engr.sgi.com>
 <45D48075.8000709@mbligh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Matt Mackall <mpm@selenic.com>, akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Martin J. Bligh wrote:

> Absolutely agree, especially as they seem to be getting more and more
> complicated and the rules get more and more obscure. (and we all get
> old ;-))

Could we should have a comment block before each of the Set/Clear 
PageXXX blocks? And remove the weird comments after the PG_xx defs? (I 
like the line /* slab debug (Suparna wants this) */ best. Never heard
of him and it has now nothing to do with slab debug).

How about defining page flags in a different way? Do it like enum 
zone_stat_item?

enum page_flags = { PG_xx, ....., PG_yyy, NR_PG_FLAGS) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
