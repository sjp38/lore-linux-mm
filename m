Message-ID: <386250D7.EA3A0EFB@idiom.com>
Date: Thu, 23 Dec 1999 19:41:59 +0300
From: Hans Reiser <reiser@idiom.com>
MIME-Version: 1.0
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
References: <Pine.LNX.4.10.9912231643160.1341-100000@alpha.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

All I'm going to ask is that if mark_buffer_dirty gets changed again, whoever
changes it please let us know this time.....  The last two times it was changed
we weren't informed, and the first time it happened it took a long time to
figure it out.

I think that whether we make __mark_buffer_dirty or mark_buffer_dirty schedule
free is an argument over whether to name a function half-full or half-empty.  I
yield to both sides.

Hans

Andrea Arcangeli wrote:

> On Thu, 23 Dec 1999, Hans Reiser wrote:
>
> >If reiserfs had good SMP, you could stall it anywhere, and the code
> >could handle that.  But we don't, and I bet others also don't, and we
> >won't have it for some time even though we are working on it.
>
> I completly understand that we need also an atomic mark_buffer_dirty and
> to call buffer_dirty from some other place.
>
> But IMHO there's no one good reason to break all the old rock solid
> filesystems like ext2 just because there's the need of a new feature.
>
> I am not proposing to not provide a way to atomically marking a buffer
> dirty. I propose only to not change the semantic of the function called
> `mark_buffer_dirty()' as it happened now.
>
> If you want the atomic version just recall __mark_buffer_dirty() and use
> balance_dirty() by hand as soon as you can (after releasing your SMP
> locks).
>
> We can trivially replace mark_buffer_dirty() with __mark_buffer_dirty()
> with an automated script inside smart/SMP filesystems that wants to
> continue to use the current 2.3.x semantic of mark_buffer_dirty().
>
> Andrea

--
Get Linux (http://www.kernel.org) plus ReiserFS
 (http://devlinux.org/namesys).  If you sell an OS or
internet appliance, buy a port of ReiserFS!  If you
need customizations and industrial grade support, we sell them.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
