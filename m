Date: Wed, 4 Sep 2002 17:55:31 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: nonblocking-vm.patch
In-Reply-To: <3D766999.A9C14E1E@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209041755030.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Sep 2002, Andrew Morton wrote:

> > get cleaned.  We can do this by simply refusing to
> > scan that zone again for a number of jiffies, say
> > 1/4 of a second.
>
> Well, it may be better to terminate that sleep earlier if IO
> completes.

But only if enough IO completes. Otherwise we'll just end
up doing too much scanning for no gain again.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
