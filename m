Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 653406B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 13:47:07 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id h56so91335909qtc.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 10:47:07 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id h56si1110146qte.96.2017.02.06.10.47.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Feb 2017 10:47:05 -0800 (PST)
Message-ID: <1486406782.2096.9.camel@surriel.com>
Subject: Re: [PATCH] mm/autonuma: don't use set_pte_at when updating
 protnone ptes
From: Rik van Riel <riel@surriel.com>
Date: Mon, 06 Feb 2017 13:46:22 -0500
In-Reply-To: <1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: 
	<1486400776-28114-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-MVn22G2WdKfDmQ8Qj1LC"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-MVn22G2WdKfDmQ8Qj1LC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2017-02-06 at 22:36 +0530, Aneesh Kumar K.V wrote:
> Architectures like ppc64, use privilege access bit to mark pte non
> accessible.
> This implies that kernel can do a copy_to_user to an address marked
> for numa fault.
> This also implies that there can be a parallel hardware update for
> the pte.
> set_pte_at cannot be used in such scenarios. Hence switch the pte
> update to use ptep_get_and_clear and set_pte_at combination.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.
--=-MVn22G2WdKfDmQ8Qj1LC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYmMR+AAoJEM553pKExN6DCo0H/1MTESBsUw1agPUbNADBK8cO
AshsZABraHVZOTrCM82NuDRetdh/KwGN6LJmovY1vRr5NUrKv2lgQKewwykUOZ2B
KOTF3jJMuSpTT+pIduC5NIIl1KUaIFqEF3faxsZIqEwMS283hOStq1GIBCxrggco
0z2OLgXTL9RJp5Zy0FoZvY0Nzi65wkC7g6j4tDtb7tzzNL1oTtXXJ5UUeN82cGwh
4KIkZ8ceIwzmr5+7VjWMOxK4A0EYu2vDt3lQrvayKqVNvZKWLeJVzV1vKyHsh7th
JMDbrvSAPwHlL4BK0gNQ5GWTp89Lo9nZAzWS86alQxmzlr3V8v+9GhYHFUHPE5M=
=wQYs
-----END PGP SIGNATURE-----

--=-MVn22G2WdKfDmQ8Qj1LC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
