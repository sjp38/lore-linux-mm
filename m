Date: Thu, 15 Feb 2007 07:21:50 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/7] Logic to move mlocked pages
In-Reply-To: <20070214213925.13b1111a.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702150720180.10403@schroedinger.engr.sgi.com>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com>
 <20070215012510.5343.52706.sendpatchset@schroedinger.engr.sgi.com>
 <20070214213925.13b1111a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007, Andrew Morton wrote:

> There are various proposals and patches floating about to similarly leave
> anonyous pages off the LRU if there's no swap available: CONFIG_SWAP=n, no
> swapfiles online or even no-swapspace-left.  Handling this is probably more
> useful to more people than handling the munlock case, frankly.

Hmmm.. Okay but then we need to account for these pages during writeback 
ratio calculation.
 
> I think that modifying this code to also provide that function is pretty
> darn simple, and that this code should perhaps be designed with that
> extension in mind.

Yes should be easy to add.
 
> In which case it might be better to rename at least the user-visible
> meminfo fields (so we don't have to change them later) and perhaps things
> like PG_mlocked and NR_MLOCKED.  To PG_nonlru and NR_NONLRU, perhaps.

I look into it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
