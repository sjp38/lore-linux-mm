Date: Fri, 5 Jul 2002 17:31:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: vm lock contention reduction
In-Reply-To: <Pine.LNX.4.44L.0207052110590.8346-100000@imladris.surriel.com>
Message-ID: <Pine.LNX.4.44.0207051727300.1052-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 5 Jul 2002, Rik van Riel wrote:
>
> But it is, mmap() and anonymous memory don't trigger writeback.

I don't think we can fix that, without going back to the approach of
marking any writable memory as read-only and counting it at page-fault
time.

Wasn't it you who did that test-patch originally?  From what I remember,
it had basically zero downside for normal UNIX applications (shared memory
that is written to is so rare that it doesn't end up on the radar), but
was quite expensive for the DB kind of shmem usage where shared writable
memory is the major component..

There might be some way to avoid the page fault badness (the large page
stuff will do this automatically, for example), which might make the
"let's keep track of dirty mappings explicitly" approach acceptable again.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
