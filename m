Date: Wed, 19 Sep 2007 15:23:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix NUMA Memory Policy Reference Counting
In-Reply-To: <1190239421.5301.72.camel@localhost>
Message-ID: <Pine.LNX.4.64.0709191520440.3402@schroedinger.engr.sgi.com>
References: <20070830185053.22619.96398.sendpatchset@localhost>
 <1190055637.5460.105.camel@localhost>  <Pine.LNX.4.64.0709171212360.27769@schroedinger.engr.sgi.com>
  <1190057885.5460.134.camel@localhost>  <Pine.LNX.4.64.0709171241290.28361@schroedinger.engr.sgi.com>
 <1190239421.5301.72.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, eric.whitney@hp.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Lee Schermerhorn wrote:

> Bottom line:  the run to run variability seems greater than the
> difference between 23-rc4-mm1 with and without the patch.  Also, it
> appears that the contention on the page table, and perhaps the
> radix-tree in the shmem case, overshadow any differences due to the
> reference counting.  Take a look and see what you think.

Looks good. Thanks. Makes sense that the radix tree overshadows it. There 
are lots of reasons to not use shmem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
