Message-Id: <200212161610.gBGGAuB7028719@localhost.localdomain>
Date: Mon, 16 Dec 2002 11:10:55 -0500
From: Georg Nikodym <georgn@somanetworks.com>
Subject: Re: [PATCH] 2.4.20-rmap15b
In-Reply-To: <Pine.LNX.4.50L.0212122349520.17748-100000@imladris.surriel.com>
References: <Pine.LNX.4.50L.0212122349520.17748-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1"; boundary="=.7b1?sS7,Z9IM5L"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--=.7b1?sS7,Z9IM5L
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Thu, 12 Dec 2002 23:51:50 -0200 (BRST)
Rik van Riel <riel@conectiva.com.br> wrote:

> Many changes, mostly backported from 2.5 by Ben LaHaise and
> fixed up a bit more by myself. It all appears to work, but
> more testing is appropriate.
> 
> The second maintenance release of the 15th version of the reverse
> mapping based VM is now available.
> This is an attempt at making a more robust and flexible VM
> subsystem, while cleaning up a lot of code at the same time.
> The patch is available from:

Is this kernel expected to fix the occassional brief pauses/hangs that
have been happening since going to 2.4.20-rmap*?

'cause it doesn't.  I've just had several pauses.

My setup:

I8000 laptop with 512MB RAM and a big ieee1394 disk running:

Linux keller 2.4.20-rc4-rmap15b #1 Fri Dec 13 14:20:02 EST 2002 i686 i686 i386 GNU/Linux

My load:

I have 182 BK repositories containing >100K files.  I've done a bunch of
repeated cloning operations and the like and I get pauses where the
system goes idle in spite of the huge workload.  Often screen updates
still happen and music keeps playing, etc but sometimes even that stops
(and my keystrokes disappear).  These pauses are between 5 and 30
seconds in duration.

Incidentally, a colleague claimed to have seem this behaviour on a
non-rmap 2.4.20.

So the questions are the usual:

1. Known behaviour?
2. Is there any data that I should be collecting that people are
   interested in?
3. Or should I just go back to 2.4.19-rmap14b (which did not trouble me
   in this way)?

-g

--=.7b1?sS7,Z9IM5L
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQE9/fsQoJNnikTddkMRAikiAJ9TugPMj4hU48LKxX2EbkYRkj5rLACfe9vC
pUZYu7NBv2uDayks0u4iJXM=
=6RbK
-----END PGP SIGNATURE-----

--=.7b1?sS7,Z9IM5L--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
