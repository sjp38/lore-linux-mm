Date: Wed, 29 Nov 2006 08:23:52 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Slab: Remove kmem_cache_t
In-Reply-To: <456D3EFC.8030701@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611290820080.3395@woody.osdl.org>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
 <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>
 <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org>
 <456D1D82.3060001@yahoo.com.au> <20061128222409.cda8cd5e.akpm@osdl.org>
 <456D2B8E.4060802@yahoo.com.au> <20061128230837.48fcc34f.akpm@osdl.org>
 <456D3576.2060109@yahoo.com.au> <20061128234104.9e23b4b1.akpm@osdl.org>
 <456D3EFC.8030701@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 29 Nov 2006, Nick Piggin wrote:
> 
> Oh so it isn't a dependency problem, or one that prevents a cleaner
> slab bootstrapping process...

No, it really _can_ be a dependency issue.

A typedef really can only be done once. Which means that either you need 
to

 (a) avoid them (easy, clean, and simple - especially if the typedef 
     doesn't actually _buy_ you anything)

 (b) have more complicated header file structure and dependencies (for 
     example, you could have one special header that defines _just_ the 
     basic types, and have everybody include that)

 (c) declare it in multiple places, and use special markers that it's been 
     declared (see a lot of the standard header files in /usr/include for 
     thigns like this):

		#ifndef __HAVE_DECLARED_KMEM_CACHE_T
		#define __HAVE_DECLARED_KMEM_CACHE_T
		typedef struct kmem_cache kmem_cache_t
		#endif

and of the three choices, pick the simplest, cleanest, and least likely 
to cause confusion.

Hint: the winner is: "(a) don't use typedefs"

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
