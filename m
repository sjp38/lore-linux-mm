Date: Fri, 3 Aug 2001 23:37:41 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108040055090.11200-100000@touchme.toronto.redhat.com>
Message-ID: <Pine.LNX.4.33.0108032330450.1193-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 4 Aug 2001, Ben LaHaise wrote:
>
> Within reason.  I'm actually heading to bed now, so it'll have to wait
> until tomorrow, but it is fairly trivial to reproduce by dd'ing to an 8GB
> non-sparse file.  Also, duplicating a huge file will show similar
> breakdown under load.

Well, I've made a 2.4.8-pre4.

This one has marcelo's zone fixes, and my request suggestions. I'm writing
email right now with the 8GB write in the background, and unpacked and
patched a kernel. It's certainly not _fast_, but it's not too painful to
use either.  The 8GB file took 7:25 to write (including the sync), which
averages out to 18+MB/s. Which is, as far as I can tell, about the best I
can get on this 5400RPM 80GB drive with the current IDE driver (the
experimental IDE driver is supposed to do better, but that's not for
2.4.x)

An added advantage of doing the waiting in the request handling was that
this way it automatically balances reads against writes - writes cannot
cause reads to fail because they have separate request queue allocations.

Does it work reasonably under your loads?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
