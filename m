Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 9A99B38CD0
	for <linux-mm@kvack.org>; Tue,  7 Aug 2001 16:21:53 -0300 (EST)
Date: Tue, 7 Aug 2001 16:21:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108071206540.1060-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33L.0108071621180.1439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Linus Torvalds wrote:

> Lazy movement may give non-optimal heuristics, but if the
> heuristics sometimes say "don't make progress", then those
> things could have happened without the lazy code - by having the
> _real_ conditions match the ones that the lazy one happened to
> be.

Hmmmm, indeed.  All lazy movement can do is make it
easier to run into a wall, but it should still be
possible without it ...

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
