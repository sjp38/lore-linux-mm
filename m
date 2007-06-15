Date: Fri, 15 Jun 2007 01:44:45 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 5.
Message-ID: <20070615064445.GM11115@waste.org>
References: <20070615033412.GA28687@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070615033412.GA28687@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 15, 2007 at 12:34:12PM +0900, Paul Mundt wrote:
> Updated version of the SLOB NUMA support.
> 
> This version adds in a slob_def.h and reorders a bit of the slab.h
> definitions. This should take in to account all of the outstanding
> comments so far on the earlier versions.
> 
> Tested on all of SLOB/SLUB/SLAB with and without CONFIG_NUMA.
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>

This is looking good. I concur with Christoph's comment comment.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
