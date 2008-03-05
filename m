Date: Wed, 5 Mar 2008 10:52:46 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/8] slub: Fallback to order 0 and variable order slab
 support
In-Reply-To: <20080305182834.GA10678@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0803051051190.29794@schroedinger.engr.sgi.com>
References: <20080229044803.482012397@sgi.com> <20080304122008.GB19606@csn.ul.ie>
 <Pine.LNX.4.64.0803041044520.13957@schroedinger.engr.sgi.com>
 <20080305182834.GA10678@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Mar 2008, Mel Gorman wrote:

> Ok, I'm offically a tool. I had named patchsets wrong and tested slub-defrag
> instead of slub-highorder. I didn't notice until I opened the diff file to
> set the max_order. slub-highorder is being tested at the moment but it'll
> be hours before it completes.

Tool? Never heard it before. Is that an Irish term? Do not worry. That 
happens all the time in the computer industry. These days, I get 
suspicious when people claim something is perfect (100% yes!).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
