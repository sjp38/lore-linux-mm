Subject: Re: Always passing mm and vma down (was: [RFC][PATCH] Convert
	do_no_page() to a hook to avoid DFS race)
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <20030601200056.GA1471@us.ibm.com>
References: <20030530164150.A26766@us.ibm.com>
	 <20030531104617.J672@nightmaster.csn.tu-chemnitz.de>
	 <20030531234816.GB1408@us.ibm.com> <20030601122200.GB1455@x30.local>
	 <20030601200056.GA1471@us.ibm.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5tTYBd1hBuLsexo8h+jz"
Message-Id: <1054542770.5187.1.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: 02 Jun 2003 10:32:50 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

--=-5tTYBd1hBuLsexo8h+jz
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2003-06-01 at 22:00, Paul E. McKenney wrote:
> The immediate motivation is to avoid the race with zap_page_range()
> when another node writes to the corresponding portion of the file,
> similar to the situation with vmtruncate().  The thought was to
> leverage locking within the distributed filesystem, but if the
> race is solved locally, then, as you say, perhaps this is not=20
> necessary.

is said distributed filesystem open source by chance ?

--=-5tTYBd1hBuLsexo8h+jz
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA+2wuxxULwo51rQBIRAoWcAKCR5pVUn9ke2BrsWvJkwu/M0dUw1wCgjeif
VJBEg55IRamoopAs9qNxUIU=
=/XzA
-----END PGP SIGNATURE-----

--=-5tTYBd1hBuLsexo8h+jz--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
