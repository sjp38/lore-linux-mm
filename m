From: Andi Kleen <ak@suse.de>
Subject: Re: Fastpath prototype?
Date: Tue, 12 Feb 2008 11:40:11 +0100
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com> <20080211235607.GA27320@wotan.suse.de> <Pine.LNX.4.64.0802112205150.26977@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802112205150.26977@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802121140.12040.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tuesday 12 February 2008 07:06:48 Christoph Lameter wrote:
> This patch preserves the performance while only needing order 0 allocs. 
> Pretty primitive.

The per CPU caches in the zone were originally intended to be exactly
such a fast path.

That is why I find your patch pretty ironic. 

I can understand it because a lot of the page_alloc.c code is frankly
bizarre now (the file could probably really need a rewrite) and it doesn't
surprise me that the old fast path is not very fast anymore.

But if you add another fast path you should first remove the old one 
at least.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
