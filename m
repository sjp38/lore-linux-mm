Date: Thu, 4 Jul 2002 20:27:50 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: vm lock contention reduction
In-Reply-To: <3D24D4A0.D39B8F2C@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207042027060.6047-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2002, Andrew Morton wrote:

> If the machine is instead full of anon pages then everything is still
> crap because the page reclaim code is scanning zillions of pages and not
> doing much useful with them.

This is something that can be fixed with rmap, because the
kernel _will_ be able to do something useful with the anon
pages.

Now we just need to get Arjan to tune the O(1) page launder
thing he was looking at ;)

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
