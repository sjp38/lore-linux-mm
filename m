Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3BA956B004D
	for <linux-mm@kvack.org>; Thu, 21 May 2009 15:08:55 -0400 (EDT)
Message-ID: <4A15A69F.3040604@redhat.com>
Date: Thu, 21 May 2009 15:08:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] Support for sanitization flag in low-level page allocator
References: <20090520183045.GB10547@oblivion.subreption.com> <1242852158.6582.231.camel@laptop>
In-Reply-To: <1242852158.6582.231.camel@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Larry H." <research@subreption.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

> Seems like a particularly wasteful use of a pageflag. Why not simply
> erase the buffer before freeing in those few places where we know its
> important (ie. exactly those places you now put the pageflag in)?

You don't always know this at page free time.

I could see the PG_sensitive flag being used from
userspace through mmap or madvise flags.  This way
the sensitive memory from a program like gpg would
be cleaned, even if gpg died in a segfault accident.

I could also imagine the suspend-to-disk code skipping
PG_sensitive pages when storing data to disk, and
replacing it with some magic signature so programs
that use special PG_sensitive buffers can know that
their crypto key disappeared after a restore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
