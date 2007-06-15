Date: Thu, 14 Jun 2007 21:30:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 5.
In-Reply-To: <20070615033412.GA28687@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706142119540.4224@schroedinger.engr.sgi.com>
References: <20070615033412.GA28687@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jun 2007, Paul Mundt wrote:

> This version adds in a slob_def.h and reorders a bit of the slab.h
> definitions. This should take in to account all of the outstanding
> comments so far on the earlier versions.

Why are the comments on kmalloc moved() from slab.h to slob_def.h? The 
comments are only partially correct. So they probably can do less harm in 
slob_def.h. May be good if you could move them back and in the process 
make them accurate?

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
