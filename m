Date: Tue, 7 Aug 2001 12:12:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33L.0108071409540.1439-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0108071206540.1060-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ben LaHaise <bcrl@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2001, Rik van Riel wrote:
>
> Obvious, you introduced this when you decided to put
> the following two things into the kernel:

Bzzt, wrong answer. It happens with earlier 2.4.x kernels too.

It may be easier to trigger now (although the data doesn't actually seem
to support that very much either).

Regardless of any lazy movements or anything else, the VM should always
make progress.  When you claim that reclaimd gets "effectively disabled"
but the current setup, then explain how it couldn't have happened without
lazy movement.

Lazy movement may give non-optimal heuristics, but if the heuristics
sometimes say "don't make progress", then those things could have happened
without the lazy code - by having the _real_ conditions match the ones
that the lazy one happened to be.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
