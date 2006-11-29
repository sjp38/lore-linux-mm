Message-ID: <456D2B8E.4060802@yahoo.com.au>
Date: Wed, 29 Nov 2006 17:41:18 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Slab: Remove kmem_cache_t
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>	<456D0757.6050903@yahoo.com.au>	<Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>	<456D0FC4.4050704@yahoo.com.au>	<20061128200619.67080e11.akpm@osdl.org>	<456D1D82.3060001@yahoo.com.au> <20061128222409.cda8cd5e.akpm@osdl.org>
In-Reply-To: <20061128222409.cda8cd5e.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 29 Nov 2006 16:41:22 +1100
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> 
>>Andrew Morton wrote:
>>
>>>On Wed, 29 Nov 2006 15:42:44 +1100
>>>Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>>>
>>>
>>>
>>>>So what exactly is wrong with
>>>>a kmem_cache_t declaration in include files, then?
>>>
>>>
>>>a) it's a typedef and
>>>
>>>b) it's a typedef, and you cannot forward-declare typedefs.  We've hit this
>>>   a couple of times.  Header files need to include slab.h just to be able to do
>>>
>>>	extern kmem_cache_t *wozzle;
>>
>>So why doesn't
>>
>>   typedef struct kmem_cache kmem_cache_t;
>>   extern kmem_cache_t *wozzle;
>>
>>work?
>>
> 
> 
> Well, you'd just do
> 
> 	extern struct kmem_cache *wozzle;
> 
> because you "know" that struct kmem_cache == kmem_cache_t.  The compiler
> will swallow it all.
> 
> Do I need to explain how much that sucks?
> 

Well the only code that is doing this is presumably some slab internal
stuff. And that does "know" that struct kmem_cache == kmem_cache_t.
Actually, once struct kmem_cache gets moved into slab.h, I would be
interested to know what remaining forward dependencies are needed at
all. Christoph?

To be clear: this won't be some random driver or subsystem code (or
even anything outside of mm/slab.c, hopefully) that is doing this,
will it? If so then it sounds like just the kind of horrible design
that we should be trying to get away from (whether we're using
kmem_cache_t or struct kmem_cache as the caller-visible slab handle).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
