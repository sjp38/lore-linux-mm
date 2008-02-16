Message-ID: <47B6AE5F.4060700@cs.helsinki.fi>
Date: Sat, 16 Feb 2008 11:35:27 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 0/8] [RFC] SLUB: Variable order slab support
References: <20080215230811.635628223@sgi.com>
In-Reply-To: <20080215230811.635628223@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> It would be nice if the page allocator would support something like: I want a
> page sized Y but I am going to take anything smaller too. Then we could get where
> Pekka wanted to go.

Perhaps it doesn't matter as much. If the higher order allocation fails, 
we're probably badly fragmented or running out of memory, so dropping to 
order 0 sounds reasonable. The only shortcoming of that is that we might 
cause a lot of internal fragmentation within the slab for objects that 
don't fit into a page nicely.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
