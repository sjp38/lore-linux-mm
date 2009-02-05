Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E7DDB6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 22:15:13 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator
Date: Thu, 5 Feb 2009 14:14:38 +1100
References: <20090114155923.GC1616@wotan.suse.de> <84144f020902031042i31eaec14v53a0e7a203acd28b@mail.gmail.com> <alpine.DEB.1.10.0902041509320.8154@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0902041509320.8154@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902051414.39985.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thursday 05 February 2009 07:10:31 Christoph Lameter wrote:
> On Tue, 3 Feb 2009, Pekka Enberg wrote:
> > Well, the slab_hiwater() check in __slab_free() of mm/slqb.c will cap
> > the size of the queue. But we do the same thing in SLAB with
> > alien->limit in cache_free_alien() and ac->limit in __cache_free(). So
> > I'm not sure what you mean when you say that the queues will "grow
> > unconstrained" (in either of the allocators). Hmm?
>
> Nick said he wanted to defer queue processing. If the water marks are
> checked and queue processing run then of course queue processing is not
> deferred and the queue does not build up further.

I don't think I ever said anything as ambiguous as "queue processing".
This subthread was started by your concern of periodic queue trimming,
and I was definitely talking about the possibility to defer *that*.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
