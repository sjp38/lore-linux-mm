Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6390B6B002A
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:52:58 -0400 (EDT)
Date: Wed, 25 May 2011 07:52:30 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree
Message-Id: <20110525075230.da671a0e.sfr@canb.auug.org.au>
In-Reply-To: <20110524124833.GB31776@kroah.com>
References: <20110520161816.dda6f1fd.sfr@canb.auug.org.au>
	<BANLkTimjzzqTS1fELmpb0UivqseLsYOfPw@mail.gmail.com>
	<20110524025151.GA26939@kroah.com>
	<20110524135930.bb4c5506.sfr@canb.auug.org.au>
	<20110524124833.GB31776@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__25_May_2011_07_52_30_+1000_gAJguTc_PC6AUYGI"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Mike Frysinger <vapier.adi@gmail.com>, Linus <torvalds@linux-foundation.org>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dipankar Sarma <dipankar@in.ibm.com>

--Signature=_Wed__25_May_2011_07_52_30_+1000_gAJguTc_PC6AUYGI
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

On Tue, 24 May 2011 05:48:33 -0700 Greg KH <greg@kroah.com> wrote:
>
> On Tue, May 24, 2011 at 01:59:30PM +1000, Stephen Rothwell wrote:
> >=20
> > The cause was a patch from Linus ...
>=20
> Ah, ok, that makes more sense, sorry for the noise.

And it doesn't show up in many builds because musb depends on ARM ||
(BF54x && !BF544) || (BF52x && !BF522 && !BF523).  So it probably appears
in some of the overnight builds, but not the ones I do while creating
linux-next.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__25_May_2011_07_52_30_+1000_gAJguTc_PC6AUYGI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN3CieAAoJEDMEi1NhKgbs86cH/1yLYRVQyjBOXJfZTaRUJo4Y
aVUNOctPKJ1Tgt56GfV/QRQ/F7cqpY8qgEqy726wMEuPFJnpdYcqrqlGRr6eCs26
A2OlCctyr8BeXMlBk4MwCT2C6WJoJy/nY7ey7wNszkSqB+z/1KzjY63FYQrvyh9V
eqyv5A7GZmPOq60fNsm+Rns090SwrKGuvtHKYnLUFDaGhx20u745gLDw5J7LvCvS
FjbHb0XoT0RAxNY7VoPkYF0A8vVLvgcl8a1PZnwhunsWpTx4cVgoLlFvIl2raNNk
9KrSfvQDWQ+tGhl/0g0shmjn44PPQNwyeLCC9i8hBXLYOuPSx+HG8nyfDWZ+xuU=
=Q27Y
-----END PGP SIGNATURE-----

--Signature=_Wed__25_May_2011_07_52_30_+1000_gAJguTc_PC6AUYGI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
