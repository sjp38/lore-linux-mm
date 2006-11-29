Message-ID: <456D3EFC.8030701@yahoo.com.au>
Date: Wed, 29 Nov 2006 19:04:12 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Slab: Remove kmem_cache_t
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>	<456D0757.6050903@yahoo.com.au>	<Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>	<456D0FC4.4050704@yahoo.com.au>	<20061128200619.67080e11.akpm@osdl.org>	<456D1D82.3060001@yahoo.com.au>	<20061128222409.cda8cd5e.akpm@osdl.org>	<456D2B8E.4060802@yahoo.com.au>	<20061128230837.48fcc34f.akpm@osdl.org>	<456D3576.2060109@yahoo.com.au> <20061128234104.9e23b4b1.akpm@osdl.org>
In-Reply-To: <20061128234104.9e23b4b1.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 29 Nov 2006 18:23:34 +1100
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>>Any module which calls kmem_cache_create() needs to save its return value
>>>into some storage.  That storage has type `struct kmem_cache *', or
>>>kmem_cache_t *.
>>
>>And why can't it include linux/slab.h to get the proper definitions
>>(+/- typdefs)?
> 
> 
> argh.
> 
> Because then you need to include slab.h in header files which don't otherwise need it.

Oh so it isn't a dependency problem, or one that prevents a cleaner
slab bootstrapping process... Just that you'd like to skimp out on
some includes. Why didn't you say that from the start? ;)

Personally I prefer to include declarations when they are needed,
but whatever. I'll drop it, now that I know the justification for
the patch.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
