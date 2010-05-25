Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5F3D9620202
	for <linux-mm@kvack.org>; Tue, 25 May 2010 10:52:09 -0400 (EDT)
Date: Tue, 25 May 2010 09:48:56 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <20100525144037.GQ5087@laptop>
Message-ID: <alpine.DEB.2.00.1005250948180.29543@router.home>
References: <20100521211452.659982351@quilx.com> <20100524070309.GU2516@laptop> <alpine.DEB.2.00.1005240852580.5045@router.home> <20100525020629.GA5087@laptop> <alpine.DEB.2.00.1005250859050.28941@router.home> <20100525144037.GQ5087@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 May 2010, Nick Piggin wrote:

> And by the way I disagreed completely that this is a problem. And you
> never demonstrated that it is a problem.
>
> It's totally unproductive to say things like it implements its own
> "NUMAness" aside from the page allocator. I can say SLUB implements its
> own "numaness" because it is checking for objects matching NUMA
> requirements too.

SLAB implement numa policies etc in the SLAB logic. It has its own rotor
now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
