Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id EF6586B003B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 09:34:47 -0400 (EDT)
Date: Tue, 4 Jun 2013 08:34:46 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Handling NUMA page migration
Message-ID: <20130604133446.GP3658@sgi.com>
References: <201306040922.10235.frank.mehnert@oracle.com>
 <20130604115807.GF3672@sgi.com>
 <201306041414.52237.frank.mehnert@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7iMSBzlTiPOCCT2k"
Content-Disposition: inline
In-Reply-To: <201306041414.52237.frank.mehnert@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frank Mehnert <frank.mehnert@oracle.com>
Cc: Robin Holt <holt@sgi.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>


--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 04, 2013 at 02:14:45PM +0200, Frank Mehnert wrote:
> On Tuesday 04 June 2013 13:58:07 Robin Holt wrote:
> > This is probably more appropriate to be directed at the linux-mm
> > mailing list.
> >=20
> > On Tue, Jun 04, 2013 at 09:22:10AM +0200, Frank Mehnert wrote:
> > > Hi,
> > >=20
> > > our memory management on Linux hosts conflicts with NUMA page migrati=
on.
> > > I assume this problem existed for a longer time but Linux 3.8 introdu=
ced
> > > automatic NUMA page balancing which makes the problem visible on
> > > multi-node hosts leading to kernel oopses.
> > >=20
> > > NUMA page migration means that the physical address of a page changes.
> > > This is fatal if the application assumes that this never happens for
> > > that page as it was supposed to be pinned.
> > >=20
> > > We have two kind of pinned memory:
> > >=20
> > > A) 1. allocate memory in userland with mmap()
> > >=20
> > >    2. madvise(MADV_DONTFORK)
> > >    3. pin with get_user_pages().
> > >    4. flush dcache_page()
> > >    5. vm_flags |=3D (VM_DONTCOPY | VM_LOCKED)
> > >   =20
> > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
> > >      =20
> > >        VM_DONTCOPY | VM_LOCKED | 0xff)
> >=20
> > I don't think this type of allocation should be affected.  The
> > get_user_pages() call should elevate the pages reference count which
> > should prevent migration from completing.  I would, however, wait for
> > a more definitive answer.
>=20
> Thanks Robin! Actually case B) is more important for us so I'm waiting
> for more feedback :)

If you have a good test case, you might want to try adding a get_page()
in there to see if that mitigates the problem.  It would at least be
interesting to know if it has an effect.

Robin

>=20
> Frank
>=20
> > > B) 1. allocate memory with alloc_pages()
> > >=20
> > >    2. SetPageReserved()
> > >    3. vm_mmap() to allocate a userspace mapping
> > >    4. vm_insert_page()
> > >    5. vm_flags |=3D (VM_DONTEXPAND | VM_DONTDUMP)
> > >   =20
> > >       (resulting flags are VM_MIXEDMAP | VM_DONTDUMP | VM_DONTEXPAND |
> > >       0xff)
> > >=20
> > > At least the memory allocated like B) is affected by automatic NUMA p=
age
> > > migration. I'm not sure about A).
> > >=20
> > > 1. How can I prevent automatic NUMA page migration on this memory?
> > > 2. Can NUMA page migration also be handled on such kind of memory wit=
hout
> > >=20
> > >    preventing migration?
> > >=20
> > > Thanks,
> > >=20
> > > Frank
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
>=20
> --=20
> Dr.-Ing. Frank Mehnert | Software Development Director, VirtualBox
> ORACLE Deutschland B.V. & Co. KG | Werkstr. 24 | 71384 Weinstadt, Germany
>=20
> Hauptverwaltung: Riesstr. 25, D-80992 M=FCnchen
> Registergericht: Amtsgericht M=FCnchen, HRA 95603
> Gesch=E4ftsf=FChrer: J=FCrgen Kunz
>=20
> Komplement=E4rin: ORACLE Deutschland Verwaltung B.V.
> Hertogswetering 163/167, 3543 AS Utrecht, Niederlande
> Handelsregister der Handelskammer Midden-Niederlande, Nr. 30143697
> Gesch=E4ftsf=FChrer: Alexander van der Ven, Astrid Kepper, Val Maher



--7iMSBzlTiPOCCT2k
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJRrez2AAoJELMAcI/i6zvGpeAQAK2pZORRhgdsJry6AVTi9No3
o+GEZ3q/Iy1BvuTxaLr2ccL0mamHUrjbY/C465cYnIXX9/Jkf6EnoQ1JPY1BoOpv
E4NhnPGWCRVDeb8YAcMRVI5io69ppdO66zTrdhVBN3LGJ7k0wVilRbgXhVlqlL8b
ABEZ3Tiiuf+8aGJS2wfdcMk9AyqQB5szIAKT4u3TD6kxHuqQU2VwMRalZIMmmR2K
1lo2igwUuEr1MVxBY9j9kGkGClOyBQZmclPSIzYGi3jDxdbUJkA+2JeAFjt8nyYe
GVYYk59EyEHgVBb271GRhNY4kCJ+nmPgszexi2XJwWKraRw6jq28AfOggaO/EStb
5xkbGo9W9AWz2dN/vlXy+8dQlmi2ZiRlCDTr/jBdYh5IyzY7RkYrCCMjKYnW4dug
erMzpbZV620sGohvU87coCDOKfrdBu5D85WxAIBc4582whVGb5ZCMMw2mIe44gm2
/fAgqBgeSWyYls4FrWhi1nyAebEEcdvxwyHMurmdWNQYtAbNabLIOzcUABwYwWki
x73sZPsdp4hMNnWaXFkBRtgH32zTaeWK0LMsvtYYkDvNFNV1evX9vy7FLzGstkPv
PQWxt3bh6uAGH7O2svH0flMWVeoLyn5tL2VDtmackmiDwYQTo0jDysQba3bBAnHR
uAJVtN7SVuOFoyrZ/F8o
=JcAm
-----END PGP SIGNATURE-----

--7iMSBzlTiPOCCT2k--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
