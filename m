Subject: Re: The long, long life of an inactive_dirty page
From: Arjan van de Ven <arjanv@redhat.com>
Reply-To: arjanv@redhat.com
In-Reply-To: <200405121411.i4CEBt6b011774@newsguy.com>
References: <200405121411.i4CEBt6b011774@newsguy.com>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-+eYCnoufQcAqnlSaSSHv"
Message-Id: <1084373509.2778.9.camel@laptop.fenrus.com>
Mime-Version: 1.0
Date: Wed, 12 May 2004 16:51:50 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Crawford <acrawford@ieee.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-+eYCnoufQcAqnlSaSSHv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> It is my understanding that the next thing that should happen is that
> page_launder(), which is invoked when memory gets low, should come along =
and
> get those pages written, and then, on its next pass mark them inactive_cl=
ean.
>=20
> But in thise case, we have plenty of memory available and absolutely noth=
ing
> using it. So there's never any memory pressure, page_launder is never cal=
led,
> and the data is never written to disk. This is arguably a bad thing; an
> entirely idle system should not be sitting for hours or days with uncommi=
tted
> data in RAM for the obvious reason.

bdflush and co WILL commit the data to disk after like 30 seconds.
They will not move it to inactive_clean; that will happen at the first
sight of memory pressure. The code that does that notices that the data
isn't dirty and won't do a write-out just a move.



> > grep Inact_dirty /proc/meminfo
> Inact_dirty:    492240 kB
>=20
> [ ~5 minutes later ]
>=20
> >  grep Inact_dirty /proc/meminfo
> Inact_dirty:    463680 kB

Inact_dirty isn't guaranteed to be dirty, it's the list of pages that
CAN be dirty.

> That's 460MB of uncommitted data hanging around on a completely idle mach=
ine.
>=20
it's not uncommitted, as I said there are other methods that make sure
that doesn't happen.



--=-+eYCnoufQcAqnlSaSSHv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAojoFxULwo51rQBIRAhClAKCUybZHP7z6XbO7okOP+BaiAloS2gCfQUYb
EkH0wIlify3ZwrpkiMQs2Lc=
=+Tmw
-----END PGP SIGNATURE-----

--=-+eYCnoufQcAqnlSaSSHv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
