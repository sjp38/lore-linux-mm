Date: Sat, 4 Aug 2001 00:23:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108032003200.15155-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0108040022110.2526-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Ben LaHaise <bcrl@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2001, Linus Torvalds wrote:

> Please just remove the code instead. I don't think it buys you anything.

IIRC you applied the patch introducing that logic because it
gave a 25% performance increase under some write intensive
loads (or something like that).

Or are you telling us now that there wasn't a reason at all
you applied that code to your tree in the first place? ;))

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
