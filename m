Date: Sat, 19 Jul 2003 19:41:02 -0700
Subject: Re: 2.6.0-test1-mm2
Message-ID: <20030720024102.GA18576@triplehelix.org>
References: <20030719174350.7dd8ad59.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3uo+9/B/ebqu+fSQ"
Content-Disposition: inline
In-Reply-To: <20030719174350.7dd8ad59.akpm@osdl.org>
From: Joshua Kwan <joshk@triplehelix.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--3uo+9/B/ebqu+fSQ
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 19, 2003 at 05:43:50PM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test1=
/2.6.0-test1-mm2/

2.6.0-test1-mm2 requires attached patch to build with software suspend.

-Josh

--=20
Using words to describe magic is like using a screwdriver to cut roast beef.
		-- Tom Robbins

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="suspend.patch"
Content-Transfer-Encoding: quoted-printable

--- a/kernel/suspend.c	2003-07-19 19:36:25.000000000 -0700
+++ b/kernel/suspend.c	2003-07-19 19:37:40.000000000 -0700
@@ -83,7 +83,7 @@
 #define ADDRESS2(x) __ADDRESS(__pa(x))		/* Needed for x86-64 where some pa=
ges are in memory twice */
=20
 /* References to section boundaries */
-extern char _text, _etext, _edata, __bss_start, _end;
+extern char _text[], _etext[], _edata[], __bss_start[], _end[];
 extern char __nosave_begin, __nosave_end;
=20
 extern int is_head_of_free_region(struct page *);

--BOKacYhQ+x31HxR3--

--3uo+9/B/ebqu+fSQ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE/GgE+T2bz5yevw+4RAoZIAJ995ICH+8mkX0IGoQVAZpuq2nyJlgCeOwJZ
v5j9TUrWxrkHeCAsxp5drAI=
=F0QZ
-----END PGP SIGNATURE-----

--3uo+9/B/ebqu+fSQ--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
