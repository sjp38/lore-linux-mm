Date: Wed, 4 Sep 2002 18:34:08 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: nonblocking-vm.patch
In-Reply-To: <3D767997.B6B76833@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209041832100.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2002, Andrew Morton wrote:

> > But only if enough IO completes. Otherwise we'll just end
> > up doing too much scanning for no gain again.
>
> Well we want to _find_ the just-completed IO, yes?  Which implies
> parking it onto the cold end of the inactive list at interrupt
> time, or a separate list or something.

In rmap14 I'm doing the following things when scanning the
inactive list:

1) if the page was referenced, activate
2) if the page is clean, reclaim

3) if the page is written to disk, keep it at the end of
   the list where we start scanning from

4) if we don't write the page to disk (I don't submit too
   much IO at once) we move it to the far end of the inactive
   list

This means that the pages for which IO completed will be found
somewhere near the start of the list.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
