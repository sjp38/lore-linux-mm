Date: Mon, 9 Oct 2000 22:06:02 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <20001009214214.G19583@athlon.random>
Message-ID: <Pine.LNX.4.21.0010092156120.8045-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Andrea Arcangeli wrote:

> > No. It's only needed if your OOM algorithm is so crappy that
> > it might end up killing init by mistake.
> 
> The algorithm you posted on the list in this thread will kill init if
> on 4Mbyte machine without swap init is large 3 Mbytes and you execute
> a task that grows over 1M.

i think the OOM algorithm should not kill processes that have
child-processes, it should first kill child-less 'leaves'. Killing a
process that has child processes likely results in unexpected behavior of
those child-processes. (and equals to effective killing of those
child-processes as well.)

But this mechanizm can be abused (a malicious memory hog can create a
child-process just to avoid the OOM-killer) - but there are ways to avoid
this, eg. to add all the 'MM badness' points to children? Ie. a child
which has MM-abuser parent(s) will definitely be killed first.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
