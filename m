Subject: Re: new memory hotremoval patch
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <20040630111719.EBACF70A92@sv1.valinux.co.jp>
References: <20040630111719.EBACF70A92@sv1.valinux.co.jp>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-0v1/FJWE/MWwdP1vqZG+"
Message-Id: <1088595151.2706.12.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: Wed, 30 Jun 2004 13:32:31 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-0v1/FJWE/MWwdP1vqZG+
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Page "remapping" is a mechanism to free a specified page by copying the
> page content to a newly allocated replacement page and redirecting
> references to the original page to the new page.
> This was designed to reliably free specified pages, unlike the swapout
> code.

are you 100% sure the locking is correct wrt O_DIRECT, AIO or futexes ??


--=-0v1/FJWE/MWwdP1vqZG+
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA4qTPxULwo51rQBIRApJqAJ40LzBUizm4uVJAu+Um8as+ZwdLbgCfSvJR
/7dzXywO0tHE+CVP51GwdTg=
=USTE
-----END PGP SIGNATURE-----

--=-0v1/FJWE/MWwdP1vqZG+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
