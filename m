Date: Mon, 9 Oct 2000 20:47:51 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091510060.1562-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010092042480.6338-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marco Colombo <marco@esi.it>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Rik van Riel wrote:

> In that case the time the process has been running and the
> CPU time used will save the process if it's been running for
> a long time.

'importance' is not something we can measure reliably within the kernel.
And assuming that a niced, not long-running process is unimportant misses
the bus as well. What if i just started an important simulation before
going to vacation for two weeks?

> would you really care if a simulation would be killed after
> 5 minutes? [...]

yes, i would. I would probably end up not using nice values. Please, Rik,
dont penalize an unrelated kernel feature!

> [...] The objective is to destroy the least amount of work, which
> means giving a bonus to processes which have used a lot of CPU time
> already ... regardless of nice value.

your OOM code does not follow this objective:

+       /*
+        * Niced processes are most likely less important, so double
+        * their badness points.
+        */
+       if (p->nice > 0)
+               points *= 2;

Niced processes *can be just as important*.

> If you have a better algorithm, feel free to send patches.

yes. Please remove the above part.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
