Date: Mon, 17 Sep 2007 12:43:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix NUMA Memory Policy Reference Counting
In-Reply-To: <1190057885.5460.134.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709171241290.28361@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1190055637.5460.105.camel@localhost>  <Pine.LNX.4.64.0709171212360.27769@schroedinger.engr.sgi.com>
 <1190057885.5460.134.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Sep 2007, Lee Schermerhorn wrote:

> Yeah, I'll have to write a custom, multithreaded test for this, or
> enhance memtoy to attach shm segments by id and run lots of them
> together.  I'll try to get to it asap.  

Maybe my old pft.c tool would help:

http://lkml.org/lkml/2006/8/29/294

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
