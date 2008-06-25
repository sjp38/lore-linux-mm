Message-ID: <48625571.9060201@freescale.com>
Date: Wed, 25 Jun 2008 09:25:53 -0500
From: Timur Tabi <timur@freescale.com>
MIME-Version: 1.0
Subject: Re: Fw: [PATCH] Add alloc_pages_exact() and free_pages_exact()
References: <20080624135750.0c59c6b9.akpm@linux-foundation.org> <200806251139.51142.nickpiggin@yahoo.com.au>
In-Reply-To: <200806251139.51142.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Wednesday 25 June 2008 06:57, Andrew Morton wrote:
>> I'm applying this.
> 
> Fine. And IIRC there are one or two places around the kernel that
> could be converted to use it. Why not just have a node id
> argument and call it alloc_pages_node_exact? so Christoph doesn't
> have to do it himself ;)

Since I don't know anything nodes, I can't say whether this is a good idea or
not, or even how to implement it.  Sorry.

> Maybe you could also say that __GFP_COMPOUND cannot be used, and
> that the returned pages are "split" (work the same way as N
> indivudually allocated order-0 pages WRT refcounting).

Is this a suggestion for the function comments?

-- 
Timur Tabi
Linux kernel developer at Freescale

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
