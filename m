Date: Fri, 7 Jan 2000 13:46:01 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <14453.54081.644647.363133@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.10001071340490.3150-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Hans Reiser <reiser@idiom.com>, Chris Mason <mason@suse.com>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Jan 2000, Stephen C. Tweedie wrote:

>Fine, I was just looking at it from the VFS point of view, not the
>specific filesystem.  In the worst case, a filesystem can always simply
>defer marking the buffer as dirty until after the locking window has
>passed, so there's obviously no fundamental problem with having a
>blocking mark_buffer_dirty.  If we want a non-blocking version too, with
>the requirement that the filesystem then to a manual rebalance once it
>is safe to do so, that will work fine too.

I did the new mark_buffer_dirty blocking and __mark_buffer_dirty
nonblocking while fixing the 2.3.x buffer code.

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.3/2.3.36pre5/buffer-2.gz

I am running with above applyed since some day on a based 2.3.36 on Alpha
and all is worked fine so far under all kind of loads.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
