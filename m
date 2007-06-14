Date: Wed, 13 Jun 2007 23:00:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
In-Reply-To: <20070614024008.GA21749@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706132259230.2094@schroedinger.engr.sgi.com>
References: <20070613031203.GB15009@linux-sh.org> <20070613032857.GN11115@waste.org>
 <20070613092109.GA16526@linux-sh.org> <20070613131549.GZ11115@waste.org>
 <20070614024008.GA21749@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, Paul Mundt wrote:

> If we do that, then slab.h needs a bit of reordering (as we can't use the
> existing CONFIG_NUMA ifdefs that exist in slab.h, which the previous
> patches built on), which makes the patch a bit more invasive.

I guess we should create include/linux/slob_def.h analoguous to 
include/linux/slab_def and move the definitions for this into the *_def 
files.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
