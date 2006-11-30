Date: Wed, 29 Nov 2006 17:59:07 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Slab: Remove kmem_cache_t
In-Reply-To: <456E36A7.2050401@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611291755310.3513@woody.osdl.org>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
 <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>
 <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org>
 <Pine.LNX.4.64.0611282027431.3395@woody.osdl.org> <456D1FDA.4040201@yahoo.com.au>
 <Pine.LNX.4.64.0611290738270.3395@woody.osdl.org> <456E36A7.2050401@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 30 Nov 2006, Nick Piggin wrote:
> > 
> > Because they are fundamentally _different_ on different architectures.
> 
> So is struct kmem_cache for slab vs slob.

No. It's always the same. Did you read the emails I send out?

I explicitly said that it doesn't matter if the _members_ change. That's 
something else, and a typedef doesn't help at all.

A "struct kmem_cache" is always a "struct kmem_cache". I don't understand 
why you're even arguing.

In contrast, a "pdt_t" can be "unsigned long" or an anonymous struct, or 
anything else. A "u64" can be "unsigned long long" or "unsigned long" 
depending on architecture, etc. But a "struct kmem_cache" is always a 
"struct kmem_cache". 

There is ZERO advantage to a typedef here. And when there is zero 
advantage, you shouldn't use a typedef because of the _negatives_ 
associated with it that have been discussed.

So why use a typedef? 

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
