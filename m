Date: Thu, 4 Jul 2002 20:26:29 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: vm lock contention reduction
In-Reply-To: <3D24D4A0.D39B8F2C@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207042024190.6047-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jul 2002, Andrew Morton wrote:

> I'll shelve this lock contention work until we have an rmap patch
> for 2.5.   Rik, do you have an estimate on that?

I've recovered from the flight back and the flu that
hit me just after OLS, so it should be pretty soon.

I've just applied Craig Kulesa's patch on top of the
latest 2.5 bk tree and will put a few small fixes on
top of that (eg. new ARM pagetable layout).

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
