Date: Thu, 5 Sep 2002 09:35:49 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: MAP_SHARED handling
In-Reply-To: <3D7705C5.E41B5D5F@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209050934290.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Sep 2002, Andrew Morton wrote:

> One thing bugs me a little bit.

> - We'll be calling ->vm_writeback() once per page, and it'll only
>   discover a single dirty page on swapper_space.dirty_pages.

> So....  Could we do something like: if the try_to_unmap() call turned
> the page from !PageDirty to PageDirty, give it another go around the
> list?

FreeBSD is doing this and seems to be getting good results
with it, so I guess it'll improve our VM too ;)

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
