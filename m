Date: Wed, 31 Jul 2002 18:25:10 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: throttling dirtiers
In-Reply-To: <20020731171456.S10270@redhat.com>
Message-ID: <Pine.LNX.4.44L.0207311824450.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2002, Benjamin LaHaise wrote:
> On Wed, Jul 31, 2002 at 02:02:03PM -0700, Andrew Morton wrote:
> > But let's back off a bit.   The problem is that a process
> > doing a large write() can penalise innocent processes which
> > want to allocate memory.
> >
> > How to fix that?
>
> First off, make it obvious where we block in the allocation path (pawning
> off all memory reaping to kswapd et al is an easy first step here).  Then
> make allocators cycle through on a FIFO basis by using something like the
> page reservation patch I came up with a while ago.  That'll give us an
> easy place to change scheduling behaviour.

These ingredients are already in 2.4-rmap.

We need an extra component, a lower lateny shrink_cache/page_launder.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
