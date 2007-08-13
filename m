Date: Mon, 13 Aug 2007 14:21:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] [438/2many] MAINTAINERS - SLAB ALLOCATOR
In-Reply-To: <1187039557.10249.312.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708131421070.28026@schroedinger.engr.sgi.com>
References: <46bffbc9.9Jtz7kOTKn1mqlkq%joe@perches.com>
 <Pine.LNX.4.64.0708131345130.27728@schroedinger.engr.sgi.com>
 <1187039557.10249.312.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Perches <joe@perches.com>
Cc: torvalds@linux-foundation.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 13 Aug 2007, Joe Perches wrote:

> Do you want slob too?

Sure we usually have to update all the slab allocators for changes.
 
> SLAB/SLUB ALLOCATOR
> P:	Christoph Lameter
> M:	clameter@sgi.com
> P:	Pekka Enberg
> M:	penberg@cs.helsinki.fi
> L:	linux-mm@kvack.org
> S:	Maintained
> F:	include/linux/sl?b*.h
> F:	mm/sl?b.c

This one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
