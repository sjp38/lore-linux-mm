Date: Tue, 7 Aug 2001 10:08:42 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108071245250.30280-100000@touchme.toronto.redhat.com>
Message-ID: <Pine.LNX.4.31.0108071007480.31219-100000@cesium.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Ben LaHaise wrote:
>
> On Tue, 7 Aug 2001, Linus Torvalds wrote:
>
> > Try pre4.
>
> It's similarly awful (what did you expect -- there are no meaningful
> changes between the two!).

The buffer.c changes could easily cause pre5 to be more aggressive in
pushing larger dirty blocks out..

Some people report _much_ better interactive behaviour with pre4.

So it obviously depends on load.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
