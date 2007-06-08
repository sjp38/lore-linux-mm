Date: Thu, 7 Jun 2007 23:43:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
In-Reply-To: <20070608062701.GA15906@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706072341130.29274@schroedinger.engr.sgi.com>
References: <20070607011701.GA14211@linux-sh.org>
 <20070607180108.0eeca877.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com>
 <20070608032505.GA13227@linux-sh.org> <Pine.LNX.4.64.0706072027300.27295@schroedinger.engr.sgi.com>
 <20070608041303.GA13603@linux-sh.org> <Pine.LNX.4.64.0706072123560.27441@schroedinger.engr.sgi.com>
 <20070608060508.GA13727@linux-sh.org> <Pine.LNX.4.64.0706072307010.28618@schroedinger.engr.sgi.com>
 <20070608062701.GA15906@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2007, Paul Mundt wrote:

> Incidentally, the interleave map created for mempol sysinit is something
> that could also be picked up by SLUB for the allowable node map (at least
> as a starting point, exlucding cpuset constraints).

SLUB already uses that map on bootup through the page allocator. So for 
boot you can actually restrict slub without any additional patches. The 
problem is later when the policy is set to MPOL_DEFAULT.

The key problem is that the node restrictions add an additional constraint 
to the ones that SLUB already obeys.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
