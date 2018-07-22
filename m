Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6E86B0008
	for <linux-mm@kvack.org>; Sun, 22 Jul 2018 19:44:54 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l23-v6so13543809qtp.1
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 16:44:54 -0700 (PDT)
Received: from o2.20qt.s2shared.sendgrid.net (o2.20qt.s2shared.sendgrid.net. [167.89.106.65])
        by mx.google.com with ESMTPS id e16-v6si2046021qvj.200.2018.07.22.16.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 22 Jul 2018 16:44:53 -0700 (PDT)
Subject: Re: [Bug 200627] New: Stutters and high kernel CPU usage from
 list_lru_count_one when cache fills memory
References: <bug-200627-27@https.bugzilla.kernel.org/>
 <20180722164034.62bf461029073a21e591b8c3@linux-foundation.org>
From: Kevin Liu <kevin@potatofrom.space>
Message-ID: <5166980c-210e-2e68-974a-9115e5c72543@potatofrom.space>
Date: Sun, 22 Jul 2018 23:44:52 +0000 (UTC)
Mime-Version: 1.0
In-Reply-To: <20180722164034.62bf461029073a21e591b8c3@linux-foundation.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="lXPaFsTwOLHmpI3CcHlbtrFRIPR6oHJKN"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lXPaFsTwOLHmpI3CcHlbtrFRIPR6oHJKN
Content-Type: multipart/mixed; boundary="2JAu83Ezf0WAO1rN1Jb3kVZhDntfeAunI";
 protected-headers="v1"
From: Kevin Liu <kevin@potatofrom.space>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org
Message-ID: <5166980c-210e-2e68-974a-9115e5c72543@potatofrom.space>
Subject: Re: [Bug 200627] New: Stutters and high kernel CPU usage from
 list_lru_count_one when cache fills memory
References: <bug-200627-27@https.bugzilla.kernel.org/>
 <20180722164034.62bf461029073a21e591b8c3@linux-foundation.org>
In-Reply-To: <20180722164034.62bf461029073a21e591b8c3@linux-foundation.org>

--2JAu83Ezf0WAO1rN1Jb3kVZhDntfeAunI
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

> How recently?  Were earlier kernels better behaved?

I've seen this issue both on Linux 4.16.15 (admittedly using the -ck
patchset) and on vanilla Linux 4.18-rc4 (which is what I'm currently using).

I'm fairly certain that it did not occur on Linux 4.14.50, which I used
previously, but I will boot back into it to double-check and let you know.


--2JAu83Ezf0WAO1rN1Jb3kVZhDntfeAunI--

--lXPaFsTwOLHmpI3CcHlbtrFRIPR6oHJKN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEs1HlSYIZlMe4Q7sPWoJBAt/j3YYFAltVFvIACgkQWoJBAt/j
3YazIg/9G56zLvwCJClq71KaKlWgsDmIBcnozQ00eAlYNta573tc1edg1BaSSuTO
yY8G+B9RHDNTz/Re/PbQdRf0bDtWDrwQDNF+Ensem2Opt0H2aX1/bVfgdwResS2l
ZVh97bZa8UPH9dGImjwk/6S/2662SA4DC6i3DlNYijBgiZ/NpJK4ch/Wvio7Xzjf
EvZHs/Gvejp7iXvA7nJmvMHi8UM4BSIOO1ePzhaQ1iVNZXAVJ8XWPhlIGlKldq3+
zJ8fYRYfeI/nxXHIoUM723gYs6JkfwKWMJC0+1MsP43yQJtckMzyHNac5dx/Dqx2
I2jV5xZlQ2xcMfmEcHVWO4xorjbxh86LkQkyj3d/GiFqistYKgKWHDe1lDerNtg5
VUHZtT6oGIpik5N1Eotf1kMI6LNJnPps4lM2ADAlNcZQXX46Lg1bA4u0efdwz2Sl
1S1fO6rTJv7blLdTwmnVzjzBHxBssubuNLUQ2RZ809SmQVNEqW07n+ICO/Ag2yRC
2tLDGDFZ0QiI0c/ZB7bsBQoA7Rb+8wY/vKT+RLlQaNY4NSqD0DJi1nhrxIBKZTfg
BvqsUoH73AVH/qRBU1B/TSJ4FFPcfk65HQZ9d2O7G/r5zpI2xrUdmcbNuwJDP5t1
vciIzyuiHFM00SbCiZwAjqxmvZmNSYHmbff/M0DJf0a+EmC3rUQ=
=6IaB
-----END PGP SIGNATURE-----

--lXPaFsTwOLHmpI3CcHlbtrFRIPR6oHJKN--
