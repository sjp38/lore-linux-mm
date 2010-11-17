Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 25A858D0002
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 18:52:42 -0500 (EST)
Date: Wed, 17 Nov 2010 18:52:30 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
Message-ID: <20101117235230.GL3290@thunk.org>
References: <1289996638-21439-1-git-send-email-walken@google.com>
 <1289996638-21439-4-git-send-email-walken@google.com>
 <20101117125756.GA5576@amd>
 <1290007734.2109.941.camel@laptop>
 <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
 <20101117231143.GQ22876@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117231143.GQ22876@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Michel Lespinasse <walken@google.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 10:11:43AM +1100, Dave Chinner wrote:
> I don't think ->page_mkwrite can be worked around - we need that to
> be called on the first write fault of any mmap()d page to ensure it
> is set up correctly for writeback.  If we don't get write faults
> after the page is mlock()d, then we need the ->page_mkwrite() call
> during the mlock() call.

OK, so I'm not an mm hacker, so maybe I'm missing something.  Could
part of this be fixed by simply sending the write faults for
mlock()'ed pages, so page_mkwrite() gets called when the page is
dirtied.  Seems like a real waste to have the file system pre-allocate
all of the blocks for a mlock()'ed region.  Why does mlock() have to
result in the write faults getting suppressed when the page is
actually dirtied?

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
