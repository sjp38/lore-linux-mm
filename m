Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A944328026C
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 18:34:40 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u18so176492112ita.2
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 15:34:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 192si17876095ioc.48.2016.09.25.15.34.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 15:34:40 -0700 (PDT)
Message-ID: <1474842875.17726.38.camel@redhat.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
From: Rik van Riel <riel@redhat.com>
Date: Sun, 25 Sep 2016 18:34:35 -0400
In-Reply-To: <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
References: <20160911225425.10388-1-lstoakes@gmail.com>
	 <20160925184731.GA20480@lucifer>
	 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-1GiKELKriBfUjhz/AVey"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>


--=-1GiKELKriBfUjhz/AVey
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-09-25 at 13:52 -0700, Linus Torvalds wrote:
> I was kind of assuming this would go through the normal channels for
> THP patches, but it's been two weeks...
>=20
> Can I have an ACK from the involved people, and I'll apply it
> directly.. Mel? Rik?

Sorry about that, I was a little distracted with the
NUMA hinting vs mprotect bug that caused programs to
segfault.

The patch looks good to me, too.

Acked-by: Rik van Riel <riel@redhat.com>

---=C2=A0
All Rights Reversed.
--=-1GiKELKriBfUjhz/AVey
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX6FD8AAoJEM553pKExN6D+94IALpxyC9rMQk2lUQ0J8Sv8UCe
d0tIhBKpH/wHQtJXlZEgNgThH7q60dCTodLEk6BEimoqvHLG4mj08okL9DzWtDXn
mQyCAZuI6y0Ha2jXYGOyVlrN5bdcX7Mh86VbuO6X22UQpfi5XNffJL+MgT4irOGl
JuDONgO67atkxqF5SfNzw76a+pcbxiPbnSLM2zGJ8vdje2PnjvL7TefvH/eiI4Jp
VkAEO0bsEvCE1sex8YXOATOX4LG5iF/9FD4lEwiZ37O4J4oEeIBvhspeqWB8eVv9
5eXOw2vkRC2m2RuxNo3THhnxfLOSFHE4aGupAz732PO3InudEGWDbPRa6IJIX00=
=J/u3
-----END PGP SIGNATURE-----

--=-1GiKELKriBfUjhz/AVey--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
