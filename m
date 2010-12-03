Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7D96B0093
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 17:40:55 -0500 (EST)
Subject: Re: [PATCH 6/6] x86 rwsem: more precise rwsem_is_contended()
 implementation
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1291335412-16231-7-git-send-email-walken@google.com>
References: <1291335412-16231-1-git-send-email-walken@google.com>
	 <1291335412-16231-7-git-send-email-walken@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 03 Dec 2010 23:41:10 +0100
Message-ID: <1291416070.2032.92.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-12-02 at 16:16 -0800, Michel Lespinasse wrote:
> We would like rwsem_is_contended() to return true only once a contending
> writer has had a chance to insert itself onto the rwsem wait queue.
> To that end, we need to differenciate between active and queued writers.

So you're only considering writer-writer contention? Not writer-reader
and reader-writer contention?

I'd argue rwsem_is_contended() should return true if there is _any_
blocked task, be it a read or a writer.

If you want something else call it something else, like
rwsem_is_write_contended() (there's a pending writer), or
rwsem_is_read_contended() (there's a pending reader).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
