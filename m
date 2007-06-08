Date: Thu, 7 Jun 2007 18:01:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system
 init.
Message-Id: <20070607180108.0eeca877.akpm@linux-foundation.org>
In-Reply-To: <20070607011701.GA14211@linux-sh.org>
References: <20070607011701.GA14211@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, ak@suse.de, clameter@sgi.com, hugh@veritas.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007 10:17:01 +0900
Paul Mundt <lethal@linux-sh.org> wrote:

> This is an alternative approach to the MPOL_INTERLEAVE across online
> nodes as the system init policy. Andi suggested it might be worthwhile
> trying to do this dynamically rather than as a command line option, so
> that's what this tries to do.
> 
> With this, the online nodes are sized and packed in to an interleave map
> if they're large enough for interleave to be worthwhile. I arbitrarily
> chose 16MB as the node size to enable interleaving, but perhaps someone
> has a better figure in mind?
> 
> In the case where all of the nodes are smaller than that, the largest
> node is selected and placed in to the map by itself (if they're all the
> same size, the first online node gets used).
> 
> If people prefer this approach, the previous patch adding mpolinit can be
> dropped.
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>

Well I took silence as assent.

None of the above text is suitable for a changelog.  Please send a
changelog for this patch, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
