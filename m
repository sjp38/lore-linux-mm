Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5826B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 09:00:05 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id i20so14216936qti.7
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 06:00:05 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id l7si12980464qtf.254.2017.02.20.06.00.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 06:00:04 -0800 (PST)
Message-ID: <1487599059.2096.44.camel@surriel.com>
Subject: Re: [PATCH] mm/thp/autonuma: Use TNF flag instead of vm fault.
From: Rik van Riel <riel@surriel.com>
Date: Mon, 20 Feb 2017 08:57:39 -0500
In-Reply-To: <1487498395-9544-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: 
	<1487498395-9544-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-tAKb6MPDigW04a1nca7d"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


--=-tAKb6MPDigW04a1nca7d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2017-02-19 at 15:29 +0530, Aneesh Kumar K.V wrote:
> We are using wrong flag value in task_numa_falt function. This can
> result in
> us doing wrong numa fault statistics update, because we update
> num_pages_migrate
> and numa_fault_locality etc based on the flag argument passed.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--=20
All Rights Reversed.
--=-tAKb6MPDigW04a1nca7d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYqvXTAAoJEM553pKExN6DpBIH/0xVHXdjqDgwKpbVGcDTc4tT
nHFHkHTfRahyvUEghkQpKb8pQzVV27S7fEtLsXbX4QxmHrYaOY7V7aDFP929aAo1
Q/0MfGA/pjxETIFPdeHUK6w8iB3JUyI/7C7CkUwHy7afFPx9pgp6kjkEpbTKR+S6
2oaf/pHm5jJAjhmdSgxWeIVsj+JycYiYkjzxNVRxE4qcBIKdNElriHw12bT2ogOi
VTRm8vRWPX4//XU6M6UNj4mmVQOBUK39VMbAmcW6Jcw4x1KN6nFRR1L2LnFV44yE
VmYmoR12aIh+vA2EVb4qxOaAgCYxeQ5Uak/S6mnWTXrB2FPi9JlvKDClUOVq4q8=
=SbFV
-----END PGP SIGNATURE-----

--=-tAKb6MPDigW04a1nca7d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
