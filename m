Date: Sun, 1 Jul 2001 20:14:42 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Removal of PG_marker scheme from 2.4.6-pre
In-Reply-To: <Pine.LNX.4.33L.0107012358460.9312-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0107012000440.7651-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Correction: I said -ac13 was bad, but ac13 was actually ok. It was ac14
that was the problem spot.

Also note how Alan happened to merge the MM patches in the reverse order
from the preX series: in the -ac series, Rik's page_launder() patch is in
-ac14, while my VM changes are merged in -ac15. In my series, it was the
other way around: mine went in in -pre2, while Rik went into -pre3. In
both cases, it's the page_launder() thing that triggers it.

And in the -ac tree, there wasn't any interaction with other patches at
all, and ac14 has the "pure" page_launder() patch that was reversed in
-pre7.

And to make doubly sure, Tim <tcm@nac.net> also tested out various
pre-kernels and unofficial combinations. Thanks.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
