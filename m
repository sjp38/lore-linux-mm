Date: Mon, 25 Sep 2000 16:27:24 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: the new VM
In-Reply-To: <20000925162311.L22882@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251625090.9122-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

> I'm not sure if we should restrict the limiting only to the cases that
> needs them. For example do_anonymous_page looks a place that could
> rely on the GFP retval.

i think an application should not fail due to other applications
allocating too much RAM. OOM behavior should be a central thing and based
on allocation patterns, not pure luck or unluck. I always found it rude to
SIGBUS when some other application is abusing RAM but the oom detector has
not yet killed it off.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
