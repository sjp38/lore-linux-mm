Date: Wed, 27 Feb 2008 11:22:40 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/17] Slab Fragmentation Reduction V10
In-Reply-To: <20080223142055.GA6745@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0802271122090.32462@schroedinger.engr.sgi.com>
References: <20080216004526.763643520@sgi.com> <20080223000722.a37983eb.akpm@linux-foundation.org>
 <20080223142055.GA6745@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Sat, 23 Feb 2008, Andi Kleen wrote:

> I'm a little sceptical about the high order allocations in slub too 
> though. Christoph seems to think they're not a big deal, but that is 
> against a lot of conventional Linux wisdom at least.
> 
> That is one area that probably needs to be explored more.

Well there is a patchset that I posted recently that allows any slub alloc 
to fallback to an order 0 alloc. That is something slab cannot do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
