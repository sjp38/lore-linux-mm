Subject: Re: SV: Need ammo against BSD Fud
References: <Pine.LNX.4.10.9909251226070.22660-100000@imperial.edgeglobal.com>
From: "David Mentr'e" <David.Mentre@irisa.fr>
Date: 25 Sep 1999 21:05:41 +0200
In-Reply-To: James Simmons's message of "Sat, 25 Sep 1999 12:28:30 -0400 (EDT)"
Message-ID: <wd8puz6erqy.fsf@parate.irisa.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

James Simmons <jsimmons@edgeglobal.com> writes:

> Whats page colouring?

This is a scheme that tries to allocate pages to minimize cache
conflicts.

More precisely : if a process need a page, the kernel tries to give him
a page that will not conflict (that is to say will use a different cache
set) with its actual set of pages.

Some "academical" studies have shown that some gain are
possible. However I do not now any successful real-life implementation
of page colouring. 

Some time ago, David Miller (of sparc, ultrasparc and gcc-sparc64 fame)
implemented a minimal coulouring support. Should be in some archives.


david
-- 
 David.Mentre@irisa.fr -- http://www.irisa.fr/prive/dmentre/
 Opinions expressed here are only mine.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
