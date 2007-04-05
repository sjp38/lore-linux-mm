Message-ID: <46151F73.50602@redhat.com>
Date: Thu, 05 Apr 2007 09:10:27 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <4614A5CC.5080508@redhat.com>
In-Reply-To: <4614A5CC.5080508@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig453632BA735F21C22580668B"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Jakub Jelinek <jakub@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig453632BA735F21C22580668B
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

In case somebody wants to play around with Rik patch or another
madvise-based patch, I have x86-64 glibc binaries which can use it:

  http://people.redhat.com/drepper/rpms

These are based on the latest Fedora rawhide version.  They should work
on older systems, too, but you screw up your updates.  Use them only if
you know what you do.

By default madvise(MADV_DONTNEED) is used.  With the environment variable=


  MALLOC_MADVISE

one can select a different hint.  The value of the envvar must be the
number of that other hint.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enig453632BA735F21C22580668B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFGFR9z2ijCOnn/RHQRAp9HAKCj86ssdwI4UBIKEcn9IfP8PZNK5wCfULuj
3hGOJ1OttAPZqplPlMaVuhI=
=RbXm
-----END PGP SIGNATURE-----

--------------enig453632BA735F21C22580668B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
