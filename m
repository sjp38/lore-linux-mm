Subject: Re: 2.5.69-mm8
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <1053629620.596.1.camel@teapot.felipe-alfaro.com>
References: <20030522021652.6601ed2b.akpm@digeo.com>
	<1053629620.596.1.camel@teapot.felipe-alfaro.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-Uriw1KwYXfeFcOhdCdMX"
Date: 22 May 2003 14:30:41 -0500
Message-Id: <1053631843.2648.3248.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Felipe Alfaro Solana <felipe_alfaro@linuxmail.org>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-Uriw1KwYXfeFcOhdCdMX
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2003-05-22 at 13:53, Felipe Alfaro Solana wrote:
> On Thu, 2003-05-22 at 11:16, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.=
5.69-mm8/
> >=20
> > . One anticipatory scheduler patch, but it's a big one.  I have not str=
ess
> >   tested it a lot.  If it explodes please report it and then boot with
> >   elevator=3Ddeadline.
> >=20
> > . The slab magazine layer code is in its hopefully-final state.
> >=20
> > . Some VFS locking scalability work - stress testing of this would be
> >   useful.
>=20
> Running on it right now... Compiles and boots. I'm sure it won't explode
> on my face :-)
2.5.69-mm8 is bleeding for me. :)  See bugs #738 and #739.  I don't
*think* they are the same but apologies in advance if they are.  #738
appears to have been produced mostly by running LTP and #739 I got with
a combination of ftest07 and aio01 from LTP and previously just by
compiling LTP.

-Paul Larson

--=-Uriw1KwYXfeFcOhdCdMX
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iEYEABECAAYFAj7NJWEACgkQbkpggQiFDqd2+gCeNrl+UPgrObMrKHQ7bWJ3pJDK
IqsAn26oL5Llku0GoEXqjEUdoeNHx0Ak
=LlBM
-----END PGP SIGNATURE-----

--=-Uriw1KwYXfeFcOhdCdMX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
