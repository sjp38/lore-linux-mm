Message-Id: <200406190103.i5J13WWr010687@turing-police.cc.vt.edu>
Subject: Re: Atomic operation for physically moving a page 
In-Reply-To: Your message of "Fri, 18 Jun 2004 17:37:12 PDT."
             <20040619003712.35865.qmail@web10904.mail.yahoo.com>
From: Valdis.Kletnieks@vt.edu
References: <20040619003712.35865.qmail@web10904.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_2143241308P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 18 Jun 2004 21:03:32 -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashwin Rao <ashwin_s_rao@yahoo.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_2143241308P
Content-Type: text/plain; charset=us-ascii

On Fri, 18 Jun 2004 17:37:12 PDT, Ashwin Rao <ashwin_s_rao@yahoo.com>  said:
> I want to copy a page from one physical location to
> another (taking the appr. locks).

At the risk of sounding stupid, what problem are you trying to solve by copying
a page? Not only (as you note) could the page be referenced by multiple
processes, it could (conceivably) belong to a kernel slab or something, or be a
buffer for an in-flight I/O request, or any number of other possibly-racy
situations.

If it's only a specific *type* of page, or explaining why you're trying to do
it, or what timing/etc constraints you have (if it's a sufficiently rare(*) case,
it might make sense to just grab the BKL and copy the page with a memcpy().)

(*) Yes, I know the BKL isn't something you want to grab if you can help it.
However, if we're on an unlikely error path or similar and other options aren't suitable...

--==_Exmh_2143241308P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFA05DkcC3lWbTT17ARAtIwAKDIDKx6Dr1h/YWjiK9vQa1fqiNBEQCffNhl
JM0kZtJZXlIqCtmwCofKEqI=
=CR+5
-----END PGP SIGNATURE-----

--==_Exmh_2143241308P--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
