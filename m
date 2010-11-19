Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD7866B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:06:58 -0500 (EST)
Date: Fri, 19 Nov 2010 10:06:41 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering writeback
Message-ID: <20101119150641.GA5302@infradead.org>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
 <20101117125756.GA5576@amd>
 <1290007734.2109.941.camel@laptop>
 <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
 <20101117231143.GQ22876@dastard>
 <20101118133702.GA18834@infradead.org>
 <alpine.LSU.2.00.1011180934400.3210@tigran.mtv.corp.google.com>
 <20101119072316.GA14388@google.com>
 <AANLkTinzhsvx=fx8dPpnJD_P70HKDRK+tWgFyYEN2_Zm@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinzhsvx=fx8dPpnJD_P70HKDRK+tWgFyYEN2_Zm@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@google.com>
Cc: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 08:42:05AM -0500, Theodore Tso wrote:
> My vote would be against. ? If you if you mmap a sparse file and then
> try writing to it willy-nilly, bad things will happen. ?This is true without
> a mlock(). ? Where is it written that mlock() has anything to do with
> improving this situation?

Exactly.  Allocating space has been a side-effect on a handfull
filesystem for about 20 kernel releases.

> If userspace wants to call fallocate() before it calls mlock(), it should
> do that. ?And in fact, in most cases, userspace should probably be
> encouraged to do that. ? But having mlock() call fallocate() and
> then return ENOSPC if there's no room?  Isn't it confusing that mlock()
> call ENOSPC?  Doesn't that give you cognitive dissonance?  It should
> because fundamentally mlock() has nothing to do with block allocation!!
> Read the API spec!

Indeed.  There is no need to make mlock + flag a parallel-API to
fallocate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
