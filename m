Date: Mon, 9 Oct 2000 21:42:14 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009214214.G19583@athlon.random>
References: <20001009210503.C19583@athlon.random> <Pine.LNX.4.21.0010091606420.1562-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010091606420.1562-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 09, 2000 at 04:07:32PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ingo Molnar <mingo@elte.hu>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 04:07:32PM -0300, Rik van Riel wrote:
> No. It's only needed if your OOM algorithm is so crappy that
> it might end up killing init by mistake.

The algorithm you posted on the list in this thread will kill init if on 4Mbyte
machine without swap init is large 3 Mbytes and you execute a task that grows
over 1M.

So I repeat again: for correctness you should either fix the oom algorithm and
demonstrate with math that it can't kill init or fix the bug using a magic
check.

Since it's not going to be possible to proof that an oom algorithm won't kill
init (also considering init isn't always /sbin/init) the magic check is going
to be the only bugfix possible.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
