Date: Mon, 9 Oct 2000 13:40:31 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010092156120.8045-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10010091339300.1438-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 9 Oct 2000, Ingo Molnar wrote:
> 
> i think the OOM algorithm should not kill processes that have
> child-processes, it should first kill child-less 'leaves'. Killing a
> process that has child processes likely results in unexpected behavior of
> those child-processes. (and equals to effective killing of those
> child-processes as well.)

I disagree - if we start adding these kinds of heuristics to it, it wil
just be a way for people to try to confuse the OOM code. Imagine some bad
guy that does 15 fork()'s and then tries to OOM...

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
