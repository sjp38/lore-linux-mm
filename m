Date: Tue, 7 Aug 2001 13:50:52 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33L.0108071621180.1439-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0108071232001.1031-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Rik van Riel wrote:
>
> Hmmmm, indeed.  All lazy movement can do is make it
> easier to run into a wall, but it should still be
> possible without it ...

Yes.

One of the things this problem seems to show is that "kswapd" really does
too many different things.

Some people who wake up kswapd really want kswapd to work at _freeing_
pages. Exactly because things like network traffic, buffer flushing etc
may not be able to do everything due to atomicity constraints or fear of
deadlocks.

At the same time, kswapd _also_ ends up doing background aging, so kswapd
basically wakes up itself once a second. And when kswapd wakes up itself
it does _not_ want to actively free pages, so it has to have that test for
"free_shortage()"..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
