Date: Mon, 9 Oct 2000 17:47:19 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.10.10010091339300.1438-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010091744400.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Linus Torvalds wrote:
> On Mon, 9 Oct 2000, Ingo Molnar wrote:
> > 
> > i think the OOM algorithm should not kill processes that have
> > child-processes, it should first kill child-less 'leaves'. Killing a
> > process that has child processes likely results in unexpected behavior of
> > those child-processes. (and equals to effective killing of those
> > child-processes as well.)
> 
> I disagree - if we start adding these kinds of heuristics to it,
> it wil just be a way for people to try to confuse the OOM code.
> Imagine some bad guy that does 15 fork()'s and then tries to
> OOM...

Also, the only way to prevent bad things like this is userbeans,
the per-user resource quotas; until we have that there will ALWAYS
be ways to fool the OOM killer. It is just a stop-gap measure to
recover from a very bad situation...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
