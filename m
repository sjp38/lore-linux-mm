Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E96F280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 04:47:36 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w50so10992355wrc.4
        for <linux-mm@kvack.org>; Sun, 21 May 2017 01:47:36 -0700 (PDT)
Received: from mail.zeus03.de (www.zeus03.de. [194.117.254.33])
        by mx.google.com with ESMTPS id n123si15699444wmn.77.2017.05.21.01.47.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 01:47:35 -0700 (PDT)
Date: Sun, 21 May 2017 10:47:34 +0200
From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH 3/3] zswap: Delete an error message for a failed memory
 allocation in zswap_dstmem_prepare()
Message-ID: <20170521084734.GB1456@katana>
References: <05101843-91f6-3243-18ea-acac8e8ef6af@users.sourceforge.net>
 <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="/NkBOFFp2J2Af1nK"
Content-Disposition: inline
In-Reply-To: <bae25b04-2ce2-7137-a71c-50d7b4f06431@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org


--/NkBOFFp2J2Af1nK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Markus, can you please stop CCing me on every of those patches?

> Omit an extra message for a memory allocation failure in this function.
>=20
> This issue was detected by using the Coccinelle software.
>=20
> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-R=
efactor_Strings-WSang_0.pdf
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

And why do you create a patch for every occasion in the same file? Do
you want to increase your patch count?


--/NkBOFFp2J2Af1nK
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEOZGx6rniZ1Gk92RdFA3kzBSgKbYFAlkhVCIACgkQFA3kzBSg
Kbb74A//Vui9k5WWaO8BMIJ97ghZM6BqaDZAnnaOcwV77DPCO7YKvF+dfDWkiXkK
XRh9LynNwiotBL0uw9PdYhdrCVzMVl7QXEOr9KakDUNSt1SV0gcNDq3lErR5uPm8
uqYrJSW53ja2t59rMIIaY2ckmZ0EXxXLaC8E9GDVYgPZDnkexlTRvbvpdLTRd34c
1L8FtBOuyTcLTO//FaOWcSeXVLV44JrXmPCFBGxxwVhgE1Px5RPM97MnFZ+UGPzR
0vHWh3U9bsAkCRalwH22vzE25lMXl8x4sl3Q97sZBnH2xDT8P3SITICaFXw4TiZD
Y94DGwYtQVM2acuEY3ZYbMMeCv42lVpAHVX4jbr97FJ1MmiEW4oZzDGtg4XUW6lH
b/vxLokXRAlNRjQ9yb/t/OzupMGDL05cVqCuMTG2T/GCycntiimGYpuOPcMUjCkG
ywWJtCISDnkZtoc5zXT6mtURx5FWbgZBucLX0qWqcl+qPetOW/jXjG527hXj0t6E
Uqwg7owY6jeosRCsT2Qc+L1mL0HG9tI2Js9zwVKo5lZ5NGTZIHhGlnO4h1ezrulD
73SsZIY/ZEHC9HbkSPij/zGv1DapwzlmYJSpX8wSRj8ZGzud7bHmQitQ1ntSWusm
baKNeP1zgUSltLDZpKTO99ck5NbdC+8yw2NWZdDz+QK1SqZeZCc=
=28Qh
-----END PGP SIGNATURE-----

--/NkBOFFp2J2Af1nK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
