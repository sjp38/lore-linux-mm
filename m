Message-ID: <456E3E98.5010706@yahoo.com.au>
Date: Thu, 30 Nov 2006 13:14:48 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Slab: Remove kmem_cache_t
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com> <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com> <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org> <Pine.LNX.4.64.0611282027431.3395@woody.osdl.org> <456D1FDA.4040201@yahoo.com.au> <Pine.LNX.4.64.0611290738270.3395@woody.osdl.org> <456E36A7.2050401@yahoo.com.au> <Pine.LNX.4.64.0611291755310.3513@woody.osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611291755310.3513@woody.osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Thu, 30 Nov 2006, Nick Piggin wrote:
> 
>>>Because they are fundamentally _different_ on different architectures.
>>
>>So is struct kmem_cache for slab vs slob.
> 
> 
> No. It's always the same. Did you read the emails I send out?
> 
> I explicitly said that it doesn't matter if the _members_ change. That's 
> something else, and a typedef doesn't help at all.
> 
> A "struct kmem_cache" is always a "struct kmem_cache". I don't understand 
> why you're even arguing.
> 
> In contrast, a "pdt_t" can be "unsigned long" or an anonymous struct, or 
> anything else. A "u64" can be "unsigned long long" or "unsigned long" 
> depending on architecture, etc. But a "struct kmem_cache" is always a 
> "struct kmem_cache". 

Oh yeah, I was thinking you could put it in a struct anyway, but I get
your point about struct passing performance (even if it doesn't happen
much in the vm code).

> 
> There is ZERO advantage to a typedef here. And when there is zero 
> advantage, you shouldn't use a typedef because of the _negatives_ 
> associated with it that have been discussed.
> 
> So why use a typedef?

I guess I'm not arguing to use the typedef so much as I wanted to know why
it is being removed (ie. why now). Do you think that avoiding the slab.h
include when some code just needs a struct kmem_cache * is a good policy?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
