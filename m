Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0ADFA6B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 11:09:24 -0400 (EDT)
Date: Mon, 24 May 2010 10:06:08 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <20100524070309.GU2516@laptop>
Message-ID: <alpine.DEB.2.00.1005240852580.5045@router.home>
References: <20100521211452.659982351@quilx.com> <20100524070309.GU2516@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 May 2010, Nick Piggin wrote:

> Well I'm glad you've conceded that queues are useful for high
> performance computing, and that higher order allocations are not
> a free and unlimited resource.

Ahem. I have never made any such claim and would never make them. And
"conceding" something ???

The "unqueueing" was the result of excessive queue handling in SLAB due and
the higher order allocations are a natural move in HPC to gain performance.

> I hope we can move forward now with some objective, testable
> comparisons and criteria for selecting one main slab allocator.

If can find criteria that are universally agreed upon then yes but that is
doubtful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
