Date: Mon, 9 Oct 2000 20:42:26 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <20001009202844.A19583@athlon.random>
Message-ID: <Pine.LNX.4.21.0010092040300.6338-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Byron Stanoszek <gandalf@winds.org>, Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Andrea Arcangeli wrote:

> On Fri, Oct 06, 2000 at 04:19:55PM -0400, Byron Stanoszek wrote:
> > In the OOM killer, shouldn't there be a check for PID 1 just to enforce that
> 
> Init can't be killed in 2.2.x latest, the same bugfix should be forward
> ported to 2.4.x.

I believe we should not special-case init in this case. If the OOM would
kill init then we *want* to know about it ASAP, because it's either a bug
in the OOM code or a memory leak in init. Both things are very bad, and
ignoring the kill would just preserve those bugs artificially.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
