Date: Fri, 27 Dec 2002 12:02:56 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: shared pagetable benchmarking
In-Reply-To: <E18RwtV-0001up-00@starship>
Message-ID: <Pine.LNX.4.44.0212271201130.21930-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@digeo.com>, Dave McCracken <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Dec 2002, Daniel Phillips wrote:
> 
> Did you ask Linus?  To my thinking, if it breaks even on small forks and wins
> on the big forks that are bothering the database people etc (and aren't we 
> all database people in the end) it's a clear win.

It doesn't break even on small forks. It _slows_them_down_.

I personally think that small forks are a hell of a lot more important
than big ones, since big ones happen rarely and don't tend to be all that
performance-critical anyway.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
