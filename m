Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D191F620202
	for <linux-mm@kvack.org>; Tue, 25 May 2010 11:12:37 -0400 (EDT)
Date: Wed, 26 May 2010 01:12:32 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
Message-ID: <20100525151232.GT5087@laptop>
References: <20100521211452.659982351@quilx.com>
 <20100524070309.GU2516@laptop>
 <alpine.DEB.2.00.1005240852580.5045@router.home>
 <20100525020629.GA5087@laptop>
 <alpine.DEB.2.00.1005250859050.28941@router.home>
 <20100525144037.GQ5087@laptop>
 <alpine.DEB.2.00.1005250948180.29543@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005250948180.29543@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 25, 2010 at 09:48:56AM -0500, Christoph Lameter wrote:
> On Wed, 26 May 2010, Nick Piggin wrote:
> 
> > And by the way I disagreed completely that this is a problem. And you
> > never demonstrated that it is a problem.
> >
> > It's totally unproductive to say things like it implements its own
> > "NUMAness" aside from the page allocator. I can say SLUB implements its
> > own "numaness" because it is checking for objects matching NUMA
> > requirements too.
> 
> SLAB implement numa policies etc in the SLAB logic. It has its own rotor
> now.

We all know. I am saying it is unproductive because you just claim
that it is some fundamental problem without why it is a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
