Date: Mon, 9 Oct 2000 22:22:52 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091707580.1562-200000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010092219510.8045-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Rik van Riel wrote:

> Note that the OOM killer already has this code built-in, but it may be

oops, i didnt notice (really!). One comment: 5*HZ in your code is way too
much for counter, and it might break the scheduler in the future. (right
now those counter values are unused, RT priorities start at 1000, so it
cannot cause harm, but one never knows.) Please use MAX_COUNTER instead.

The SCHED_YIELD thing is a nice trick, it should be added to my signal.c
change as well, without the schedule().

> a good idea to have SIGKILL delivery speeded up for every SIGKILL ...

yep.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
