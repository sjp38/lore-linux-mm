Date: Wed, 29 Nov 2006 11:16:52 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab: Remove kmem_cache_t
In-Reply-To: <456D2B8E.4060802@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611291115530.16189@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
 <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>
 <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org>
 <456D1D82.3060001@yahoo.com.au> <20061128222409.cda8cd5e.akpm@osdl.org>
 <456D2B8E.4060802@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006, Nick Piggin wrote:

> Well the only code that is doing this is presumably some slab internal
> stuff. And that does "know" that struct kmem_cache == kmem_cache_t.
> Actually, once struct kmem_cache gets moved into slab.h, I would be
> interested to know what remaining forward dependencies are needed at
> all. Christoph?

There are some very elementary header files. See the earlier 
linux-mm discussion on the removal of the global caches from slab.h.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
