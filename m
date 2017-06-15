Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C198D6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:29:21 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z5so18340776qta.12
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 12:29:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b199si89400qka.362.2017.06.15.12.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 12:29:20 -0700 (PDT)
Message-ID: <1497554957.20270.97.camel@redhat.com>
Subject: Re: [PATCH v2 02/10] x86/mm: Remove reset_lazy_tlbstate()
From: Rik van Riel <riel@redhat.com>
Date: Thu, 15 Jun 2017 15:29:17 -0400
In-Reply-To: <7e505cd9680b60f6995443bd1320deb7689125f0.1497415951.git.luto@kernel.org>
References: <cover.1497415951.git.luto@kernel.org>
	 <7e505cd9680b60f6995443bd1320deb7689125f0.1497415951.git.luto@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-UpVhvwRuisgDNML3dgV2"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>


--=-UpVhvwRuisgDNML3dgV2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-06-13 at 21:56 -0700, Andy Lutomirski wrote:
> The only call site also calls idle_task_exit(), and idle_task_exit()
> puts us into a clean state by explicitly switching to init_mm.
>=20
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed
--=-UpVhvwRuisgDNML3dgV2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZQuANAAoJEM553pKExN6D/qwIALVPG440f8JB3L77eJn4ChGr
NCshTTb4PBT3qI3qW1pZXxybH3aJxV8UrZDo3gkRSad0lxpntKlMKWrD4ARpDGUx
DkYhPg6SXssvTe6eeNgyax5FIgq3/kGohvf6gUJFSXBupA3Ru7ffq2SxhOmikASi
qPz3T09hTKgvyWBJ+A68xfR4DcpHfRkTVKeMD9f02ZXuK1VkV+nOzBaV0lTD4mWy
SJlLjio6JZ8I2dN/K1XKbarPYL176pCFhZzQLoyIqPRes0V4lb0c/OWO9uida5vX
74etp6lclz285T2hwe9HMaZq3P/cTM2BQHp4129mb+0dF2fhbc9X2QwBzpp6bMc=
=Iywz
-----END PGP SIGNATURE-----

--=-UpVhvwRuisgDNML3dgV2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
