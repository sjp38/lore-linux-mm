Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: 0-order allocation problem
Date: Thu, 16 Aug 2001 10:30:35 +0200
References: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com>
In-Reply-To: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010816082419Z16176-1232+379@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 15, 2001 10:45 pm, Linus Torvalds wrote:
> In short: we do have freeable memory. But it won't just come back to us.

Side note: we have 100% guaranteed not a snowball's chance in hell of
returning the correct result for out_of_memory until we can prove that
we always obtain a halfway correct statistic for total freeable memory,
and an algorithm that delivers same to the free lists when we need it.

<warning: ramble coming>In a sense, except for process data, almost
all pages are freeable, the only variable is the amount of time it
takes to free them.  Sometimes we'll have to wait for writeouts to
file or swap to complete, in other cases we have to wait for users
to drop their use counts on pages and/or buffers.  The significant
exception to this is pinned pages.  IMHO, the VM needs to know how
many pages are pinned and right now it has no reliable way to tell
because the use count is overloaded.  So how about adding a PG_pinned
flag, and users need to set it for any page they intend to pin.  We
can supply pin_page(page) and unpin_page(page) mm ops to bury the
details of keeping the necessary stats.  I've thought this through a
little more than I've written here, but I'll stop now and wait for
flames, fuzzies, whatever on the basic concept[1].</warning>

--
Daniel

[1] 2.5 of course
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
