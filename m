From: Thomas Schlichter <thomas.schlichter@web.de>
Subject: Re: 2.6.0-test8-mm1
Date: Tue, 21 Oct 2003 10:39:18 +0200
References: <20031020020558.16d2a776.akpm@osdl.org> <200310210046.h9L0kHFg001918@turing-police.cc.vt.edu> <20031020185613.7d670975.akpm@osdl.org>
In-Reply-To: <20031020185613.7d670975.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_7CPl/oUqXn2R+gk";
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200310211039.23358.thomas.schlichter@web.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Valdis.Kletnieks@vt.edu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Simmons <jsimmons@infradead.org>
List-ID: <linux-mm.kvack.org>

--Boundary-02=_7CPl/oUqXn2R+gk
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 21 October 2003 03:56, Andrew Morton wrote:
> Valdis.Kletnieks@vt.edu wrote:
> > I've not had a chance to play binary search on those options yet..=20
> > Graphics card is an NVidia GeForce 440Go, and was previous working just
> > fine with framebuffer over on vc1-6 and NVidia's driver on an XFree86 on
> > vc7. (OK, I admit I didn't stress test the framebuffer side much past
> > "penguins and scroiled text"...)
>
> Thanks.  You're now the third person (schlicht@uni-mannheim.de,
> jeremy@goop.org) who reports that the weird oopses (usually in
> invalidate_list()) go away when the fbdev code is disabled.
>
> You're using vesafb on nvidia, Jeremy is using vesafb on either radeon or
> nvidia, not sure about Thomas.

Sorry for not mentioning it!
I use(d) vesafb on a Nvidia GeForce 2 MX 440.

> Has anyone tried CONFIG_DEBUG_SLAB and CONFIG_DEBUG_PAGEALLOC, see if that
> turns anything up?

I didn't yet, but I'll try now...

--Boundary-02=_7CPl/oUqXn2R+gk
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQA/lPC7YAiN+WRIZzQRAqg8AJ4rh0MlSoTsKndBF2/YDtCzi3JwZwCeNdfB
ffv+e7SJsjVcJRjeR8N/LRY=
=+aaQ
-----END PGP SIGNATURE-----

--Boundary-02=_7CPl/oUqXn2R+gk--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
