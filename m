Date: Wed, 13 Jun 2007 23:01:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
In-Reply-To: <20070614024344.GB21749@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706132300580.2094@schroedinger.engr.sgi.com>
References: <20070613031203.GB15009@linux-sh.org> <20070613032857.GN11115@waste.org>
 <20070613092109.GA16526@linux-sh.org> <20070613131549.GZ11115@waste.org>
 <Pine.LNX.4.64.0706131546380.32399@schroedinger.engr.sgi.com>
 <20070614024344.GB21749@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, Paul Mundt wrote:

> Yes, this is what I had originally. Matt wants to go the other way,
> having the _node variants always defined, and having the non-node
> variants simply wrap in to them.
> 
> Doing that only for SLOB makes slab.h a bit messy. We could presumably
> switch to that sort of behaviour across the board, but that would cause a
> bit of churn in SLAB, so it's probably something we want to avoid.

Yes please move the functionality to include/linux/slob_def.h.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
