Date: Tue, 21 Dec 1999 14:57:29 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <14431.32449.832594.222614@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.21.9912211434320.26889-100000@Fibonacci.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 1999, Stephen C. Tweedie wrote:

>We cannot use the buffer.c dirty list anyway because bdflush can write
>those buffers to disk at any time.  Transactions have to control the

So you are talking about replacing this line:

	dirty = size_buffers_type[BUF_DIRTY] >> PAGE_SHIFT;

with:

	dirty = (size_buffers_type[BUF_DIRTY]+size_buffers_type[BUF_PINNED]) >> PAGE_SHIFT;

If you don't do that you don't need _two_ filesystems to generate too many
dirty buffers but you can potentially go OOM with only one journaling
filesystem running. As you talked about a _two_ filesystem case generating
dirty buffers on 100% of memory I thought you was talking about something
very different than the above one liner. If you was talking about it
that's fine and I agree of course.

>We're not talking about normal filesystems. :)

With "normal" filesystems I meant filesystems that are _using_
linux/fs/buffer.c.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
