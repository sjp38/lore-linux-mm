Subject: Re: 2.5.74-mm2 + nvidia (and others)
From: Christian Axelsson <smiler@lanil.mine.nu>
Reply-To: smiler@lanil.mine.nu
In-Reply-To: <6A3BC5C5B2D@vcnet.vc.cvut.cz>
References: <6A3BC5C5B2D@vcnet.vc.cvut.cz>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-T6ScaPOqk3yJfF558TWm"
Message-Id: <1057669356.6858.29.camel@sm-wks1.lan.irkk.nu>
Mime-Version: 1.0
Date: 08 Jul 2003 15:02:37 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Petr Vandrovec <VANDROVE@vc.cvut.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-T6ScaPOqk3yJfF558TWm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2003-07-08 at 14:37, Petr Vandrovec wrote:
> On  8 Jul 03 at 13:35, Christian Axelsson wrote:
> > On Tue, 2003-07-08 at 13:23, Flameeyes wrote:
> > > On Tue, 2003-07-08 at 13:01, Petr Vandrovec wrote:
> > > > vmware-any-any-update35.tar.gz should work on 2.5.74-mm2 too.
> > > > But it is not tested, I have enough troubles with 2.5.74 without mm=
 patches...
> > > vmnet doesn't compile:
> > >=20
> > > make: Entering directory `/tmp/vmware-config1/vmnet-only'
> > > In file included from userif.c:51:
> > > pgtbl.h: In function `PgtblVa2PageLocked':
> > > pgtbl.h:82: warning: implicit declaration of function `pmd_offset'
> > > pgtbl.h:82: warning: assignment makes pointer from integer without a
> > > cast
> > > make: Leaving directory `/tmp/vmware-config1/vmnet-only'
> >=20
> > I get exactly the same errors. BTW I got these on vanilla 2.5.74 aswell=
.
>=20
> Either copy compat_pgtable.h from vmmon to vmnet, or grab
> vmware-any-any-update36. I forgot to update vmnet's copy of this file.

Still getting same errors. However if I copy pgtbl.h from vmmon it
compiles. vmmon uses pmd_offset_map instead of pmd_offset

--=20
Christian Axelsson
smiler@lanil.mine.nu

--=-T6ScaPOqk3yJfF558TWm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQA/CsDryqbmAWw8VdkRAsgFAKCOYd/iwuZm01BvRppKLJJsbrxXaQCfeaWd
cQ1ctAaj07A9JlDIwUpfv/8=
=6A4V
-----END PGP SIGNATURE-----

--=-T6ScaPOqk3yJfF558TWm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
