Message-ID: <456D0757.6050903@yahoo.com.au>
Date: Wed, 29 Nov 2006 15:06:47 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Slab: Remove kmem_cache_t
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> This patch replaces all uses of kmem_cache_t with struct kmem_cache.
> 

kmem_cache really is an opaque type outside of mm/slab.c, isn't it?

In which case, shouldn't the policy be to go the other way? Like
the pagetable types, for example.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
