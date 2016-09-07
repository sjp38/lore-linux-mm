Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7856B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 21:22:10 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id m62so2141697vkd.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 18:22:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n5si740368ywb.290.2016.09.06.18.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 18:22:09 -0700 (PDT)
Message-ID: <1473211325.32433.182.camel@redhat.com>
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
From: Rik van Riel <riel@redhat.com>
Date: Tue, 06 Sep 2016 21:22:05 -0400
In-Reply-To: <563d8230-4a58-cb5f-ef3e-b89745234252@gmail.com>
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
 <33981.1472677706@turing-police.cc.vt.edu>
 <6b5d162b-c09d-85c0-752f-a18f35bbbb5c@gmail.com>
 <1473209511.32433.179.camel@redhat.com>
	 <563d8230-4a58-cb5f-ef3e-b89745234252@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-3U0mkAzkQmlzkWuFezRK"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nick <xerofoify@gmail.com>, Valdis.Kletnieks@vt.edu, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-3U0mkAzkQmlzkWuFezRK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-09-06 at 21:12 -0400, nick wrote:
>=20
> On 2016-09-06 08:51 PM, Rik van Riel wrote:
> > On Wed, 2016-08-31 at 17:28 -0400, nick wrote:
> > > =C2=A0
> > > Rather then argue since that will go nowhere. I am posing actual
> > > patches that have been tested on
> > > hardware.=C2=A0
> >=20
> > But not by you, apparently.
> >=20
> > The patch below was first posted by somebody else
> > in 2013: https://lkml.org/lkml/2013/7/11/93
> >=20
> > When re-posting somebody else's patch, you need to
> > preserve their From: and Signed-off-by: headers.
> >=20
> > See Documentation/SubmittingPatches for the details
> > on that.
> >=20
> > Pretending that other people's code is your own
> > is not only very impolite, it also means that
> > the origin of the code, and permission to distribute
> > it under the GPL, are in question.
> >=20
> > Will you promise to not claim other people's code as
> > your own?
> >=20
> I wasn't aware of that. Seems it was fixed before I got to=C2=A0
> it but was never merged. Next time I will double check if the
> patch work is already out there. Also have this patch but the
> commit message needs to be reworked:

Can you tell us what hardware you tested this
patch on?

What kind of system did you plug the ninja32
controller into?

> From: Nicholas Krause <xerofoify@gmail.com>
> Date: Wed, 31 Aug 2016 17:20:10 -0400
> Subject: [PATCH] ata:Fix incorrect function call ordering in
> =C2=A0pata_ninja32_init_one
>=20
> This fixes a incorrect function call ordering making cards using
> this driver not being able to be read or written to due to the
> incorrect calling of pci_set_master before other parts of the
> card are registered before the pci master bus should be registered.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
> =C2=A0drivers/ata/pata_ninja32.c | 2 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/ata/pata_ninja32.c b/drivers/ata/pata_ninja32.c
> index 44f97ad..89320c9 100644
> --- a/drivers/ata/pata_ninja32.c
> +++ b/drivers/ata/pata_ninja32.c

--=20

All Rights Reversed.
--=-3U0mkAzkQmlzkWuFezRK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXz2u9AAoJEM553pKExN6DXgwH/17YuPzHbW4kgdlVWu60U8WB
IQGuFECNw2A0a964ijIS56rH0HMz6BV0R3e1Af+urD67Lqqv0rS9+rfDdr5jNmvs
Y43f4ZDrVVSZfQ+JZTXIUXjD+HUFsRPqglkdOSIQ5rVrjUpWb4SPTiYAs/C3nSBq
234EevNVn3cMHmfZEBr1pOWZBWMLMRpataklfGS8hbqdmnZ2Zt2S0Y9RzzFoHDjn
wGupeuvyxfKPQJqPx5bAYhJTMnlxbX6y+DVraAFndx1YX0k+lBavPozGHseFv8Dm
zziOgAw15t0UxiHrU2+lRYcBULd7IhkVSBTD05sLVOc1TreSikUSLxu2w/v4eNs=
=MRse
-----END PGP SIGNATURE-----

--=-3U0mkAzkQmlzkWuFezRK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
