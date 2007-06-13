Message-ID: <466F67A4.9080104@yahoo.com.au>
Date: Wed, 13 Jun 2007 13:42:28 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
References: <20070613031203.GB15009@linux-sh.org> <466F6351.9040503@yahoo.com.au> <20070613033306.GA15169@linux-sh.org> <466F66E3.8020200@yahoo.com.au>
In-Reply-To: <466F66E3.8020200@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Paul Mundt <lethal@linux-sh.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Paul Mundt wrote:

>> That's why I tossed in the node id matching in slob_alloc() for the
>> partial free page lookup. At the moment the logic obviously won't scale,
>> since we end up scanning the entire freelist looking for a page that
>> matches the node specifier. If we don't find one, we could rescan and
>> just grab a block from another node, but at the moment it just continues
>> on and tries to fetch a new page for the specified node.
> 
> 
> Oh, I didn't notice that. OK, sorry that would work.

OTOH, there are lots of places that don't specify the node explicitly,
but most of them prefer the allocation to come from the current node...
and that case isn't handled very well is it?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
