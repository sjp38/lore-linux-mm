Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 21A346B006E
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 10:11:39 -0500 (EST)
Received: by mail-oi0-f43.google.com with SMTP id z81so4223245oif.2
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 07:11:38 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id u2si7987657obx.48.2015.01.20.07.11.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 07:11:38 -0800 (PST)
Date: Tue, 20 Jan 2015 09:10:38 -0600
From: Felipe Balbi <balbi@ti.com>
Subject: Re: [next-20150119]regression (mm)?
Message-ID: <20150120151038.GC6556@saruman>
Reply-To: <balbi@ti.com>
References: <54BD33DC.40200@ti.com>
 <20150119174317.GK20386@saruman>
 <20150120001643.7D15AA8@black.fi.intel.com>
 <20150120114555.GA11502@n2100.arm.linux.org.uk>
 <20150120140546.DDCB8D4@black.fi.intel.com>
 <CAOMZO5D-Z-FLPmQ4Yy3rxBa-FebLcnG9TSzg3F-MF-TFBBMrwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OBd5C1Lgu00Gd/Tn"
Content-Disposition: inline
In-Reply-To: <CAOMZO5D-Z-FLPmQ4Yy3rxBa-FebLcnG9TSzg3F-MF-TFBBMrwQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabio Estevam <festevam@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Nishanth Menon <nm@ti.com>, Felipe Balbi <balbi@ti.com>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-omap <linux-omap@vger.kernel.org>

--OBd5C1Lgu00Gd/Tn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 20, 2015 at 12:50:59PM -0200, Fabio Estevam wrote:
> On Tue, Jan 20, 2015 at 12:05 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Russell King - ARM Linux wrote:
> >> On Tue, Jan 20, 2015 at 02:16:43AM +0200, Kirill A. Shutemov wrote:
> >> > Better option would be converting 2-lvl ARM configuration to
> >> > <asm-generic/pgtable-nopmd.h>, but I'm not sure if it's possible.
> >>
> >> Well, IMHO the folded approach in asm-generic was done the wrong way
> >> which barred ARM from ever using it.
> >
> > Okay, I see.
> >
> > Regarding the topic bug. Completely untested patch is below. Could anyb=
ody
> > check if it helps?
>=20
> Yes, it helps. Now I can boot mx6 running linux-next 20150120 with
> your patch applied.

worked fine here too with AM437x SK, AM437x IDK and BeagleBoneBlack.

thanks

--=20
balbi

--OBd5C1Lgu00Gd/Tn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUvm/uAAoJEIaOsuA1yqREP4gP/AnR/1cR2pv/Ev9OLcxQYXku
ei4TJAaA2TXLne1aoqEUDdrhdt1iGwUe8hmFqe/OHkEpJuz65AkbXtEOtrcsCary
6DiJ+/GwMqo+rCT71FHZUCmlipIIKFzqMFsKEtKn2eKaETJ/njuGNZ6Lrzt3xA0l
sdqgI8Wy8PqurtB2BIM+OfPGpaNY0qd0yKuHLxOqEnDpxgdgVFcVjZVZgsY42UOW
vQ40UKfU387qOiu4fm2rBwuDssGsUdduyoazJv8Ym3NeoH9HTSR9LZF4I778xxRi
dMqQRru2jIaXTyKoZVNnscKTfMwiLp+DRDxELIPrfxQqC8BbUAp57RQxgAG/0afb
b4vBQTk7rFsE2Ct38rCxf3OpeZ6GGD3u2BHGQqxYEsTyOoI4r6x1K79kbYZKLs1l
Nqs59LnXpF38BgsJdoO7BmRKCQbnjYzx5V6trr1YCCMKl9lmxWy9xI6lYlBBVnCK
vdReEdsxVG2lXuUVMckTNWV6nMqqykXqPch1PFuVSn0RIWgJWAaO63u3FGbaHR2l
VFGtT2NtMP3N0b3mlW75if2wBj5fjxEiy+WJzW/QlEpFec2M8LAfdwW2S37XLXFd
kN7nizgVUkxVFPQ201SVOQwI5wqCX+WeDQ5YrESH3IYLo3gPxmA7KEqLDZ4WP5HW
gZ2m3za56GDEmB3YiK1h
=BZo1
-----END PGP SIGNATURE-----

--OBd5C1Lgu00Gd/Tn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
