Date: Sun, 19 Sep 1999 14:29:30 +0200 (CEST)
From: Rik van Riel <riel@humbolt.geo.uu.nl>
Subject: Re: Need ammo against BSD Fud
In-Reply-To: <199909172159.XAA01101@agnes.faerie.monroyaume>
Message-ID: <Pine.LNX.4.10.9909191427000.22068-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: JF Martinez <jfm2@club-internet.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Sep 1999, JF Martinez wrote:

> BSD people are writing tons of articles saying how superior BSD is
> respective to Linux.  There is a danger they will impregnate
> people with the idea: Linux=second rate system.

The BSD VM system _is_ better than the Linux one, but AFAIK
that's about the only part where we lag in such a way that
people can actually notice a difference.

I think it's time to stop the advocacy and start the design
of a better Linux VM system. The first part would be a real
zoned memory allocator. More in my next mail...

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.
--
work at:	http://www.reseau.nl/
home at:	http://www.nl.linux.org/~riel/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
