Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 09D4C6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 22:19:14 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator
Date: Thu, 5 Feb 2009 14:18:46 +1100
References: <20090114155923.GC1616@wotan.suse.de> <200902041522.01307.nickpiggin@yahoo.com.au> <alpine.DEB.1.10.0902041507050.8154@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0902041507050.8154@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902051418.47523.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thursday 05 February 2009 07:09:15 Christoph Lameter wrote:
> On Wed, 4 Feb 2009, Nick Piggin wrote:
> > That's very true, and we touched on this earlier. It is I guess
> > you can say a downside of queueing. But an analogous situation
> > in SLUB would be that lots of pages on the partial list with
> > very few free objects, or freeing objects to pages with few
> > objects in them. Basically SLUB will have to do the extra work
> > in the fastpath.
>
> But these are pages with mostly allocated objects and just a few objects
> free. The SLAB case is far worse: You have N objects on a queue and they
> are keeping possibly N pages away from the page allocator and in those
> pages *nothing* is used.

Periodic queue trimming should prevent this from becoming a big problem.
It will trim away those objects, and so subsequent allocations will come
from new pages and be densely packed. I don't think I've seen a problem
in SLAB reported from this phenomenon, so I'm not too concerned about it
at the moment.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
