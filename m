Date: Thu, 4 Jul 2002 23:16:44 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: vm lock contention reduction
In-Reply-To: <3D2501FA.4B14EB14@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207042315560.6047-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2002, Andrew Morton wrote:

> Of course, that change means that we wouldn't be able to throttle
> page allocators against IO any more, and we'd have to do something
> smarter.  What a shame ;)

We want something smarter anyway.  It just doesn't make
sense to throttle on one page in one memory zone while
the pages in another zone could have already become
freeable by now.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
