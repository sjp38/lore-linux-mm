Date: Sat, 16 Feb 2008 11:00:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/8] slub: Adjust order boundaries and minimum objects
 per slab.
In-Reply-To: <47B6A928.7000309@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0802161059420.25573@schroedinger.engr.sgi.com>
References: <20080215230811.635628223@sgi.com> <20080215230854.643455255@sgi.com>
 <47B6A928.7000309@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sat, 16 Feb 2008, Pekka Enberg wrote:

> These look quite excessive from memory usage point of view. I saw you dropping
> DEFAULT_MAX_ORDER to 4 but it seems a lot for embedded guys, at least?

What would be a good max order then? 4 means we can allocate a 64k segment 
for 16 4k objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
