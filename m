Date: Wed, 31 Jul 2002 18:35:25 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: throttling dirtiers
In-Reply-To: <3D48568F.B7A006A7@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207311834440.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Benjamin LaHaise <bcrl@redhat.com>, William Lee Irwin III <wli@holomorphy.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2002, Andrew Morton wrote:

> > First off, make it obvious where we block in the allocation path (pawning
> > off all memory reaping to kswapd et al is an easy first step here).  Then
> > make allocators cycle through on a FIFO basis by using something like the
> > page reservation patch I came up with a while ago.  That'll give us an
> > easy place to change scheduling behaviour.
>
> None of that will preferentially throttle the source of
> dirty pages, which seems a good thing to do?

But it will throttle the page dirtiers we care about, ie. the
ones allocating new memory.

I'm not sure we care too much about re-dirtying pagecache pages;
if that is happening we want to keep those pages resident anyway.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
